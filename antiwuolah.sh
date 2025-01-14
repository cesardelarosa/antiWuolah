#!/bin/bash

# Función para mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 [opciones] <archivo_pdf>"
    echo ""
    echo "Opciones:"
    echo "  -l, --remove-last          Elimina la última página del PDF."
    echo "  -h, --help                 Muestra esta ayuda."
    echo ""
    echo "Por defecto, se excluye la página 1 y, si el PDF tiene más de 5 páginas, también se excluyen las páginas 4 y 5."
}

# Función para manejar errores
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

# Parseo de argumentos
remove_last=false
input_pdf=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -l|--remove-last)
            remove_last=true
            shift
            ;;
        -h|--help)
            mostrar_ayuda
            exit 0
            ;;
        *)
            if [[ -z "$input_pdf" ]]; then
                input_pdf="$1"
            else
                echo "Error: Argumento desconocido '$1'"
                mostrar_ayuda
                exit 1
            fi
            shift
            ;;
    esac
done

# Validar argumento de entrada
if [[ -z "$input_pdf" ]]; then
    echo "Error: No se ha especificado un archivo PDF de entrada."
    mostrar_ayuda
    exit 1
fi

# Comprobar dependencias
for cmd in qpdf pdfcrop pdfjam; do
    if ! command -v "$cmd" &>/dev/null; then
        error_exit "El comando '$cmd' no está instalado."
    fi
done

# Configuración inicial
output_pdf="${input_pdf%.pdf}-SinAnuncios.pdf"
temp_pdf="$(mktemp --suffix=.pdf)"
temp_dir="$(mktemp -d)"
trap 'rm -rf "$temp_dir" "$temp_pdf"' EXIT

# Márgenes por estilo
margins_estilo1="-85 -112 -6 -17"
margins_estilo2="-12 -10 -21 -25"

# Configuración de la barra de progreso
progress_bar_length=50

# Comprobar si el archivo de entrada existe
if [[ ! -f "$input_pdf" ]]; then
    error_exit "El archivo '$input_pdf' no existe."
fi

# Obtener número de páginas
num_pages=$(qpdf --show-npages "$input_pdf") || error_exit "No se pudo leer el número de páginas del archivo '$input_pdf'."

# Definir páginas a excluir por defecto
exclude_pages=(1)
if (( num_pages > 5 )); then
    exclude_pages+=(4 5)
fi

# Si se debe eliminar la última página, añadirla a las exclusiones
if $remove_last; then
    exclude_pages+=("$num_pages")
fi

# Validar las páginas a excluir
for page in "${exclude_pages[@]}"; do
    if ! [[ "$page" =~ ^[0-9]+$ ]] || (( page < 1 || page > num_pages )); then
        error_exit "Página inválida a excluir: $page."
    fi
done

# Generar lista de páginas a incluir
pages_to_keep=""
for ((i=1; i<=num_pages; i++)); do
    if [[ ! " ${exclude_pages[@]} " =~ " $i " ]]; then
        if [[ -z "$pages_to_keep" ]]; then
            pages_to_keep="$i"
        else
            pages_to_keep="$pages_to_keep,$i"
        fi
    fi
done

# Verificar si hay páginas restantes
if [[ -z "$pages_to_keep" ]]; then
    error_exit "No hay páginas restantes después de excluir."
fi

# Eliminar páginas especificadas
qpdf "$input_pdf" --pages "$input_pdf" "$pages_to_keep" -- "$temp_pdf" &>/dev/null || error_exit "No se pudo crear el archivo temporal '$temp_pdf'."

# Actualizar el número de páginas después de exclusión
num_pages=$(qpdf --show-npages "$temp_pdf") || error_exit "No se pudo leer el número de páginas del archivo temporal '$temp_pdf'."

# Agrupar páginas según el patrón: 1 (estilo1), 2-3 (estilo2), 4 (estilo1), 5-6 (estilo2), etc.
declare -a grupos=()
declare -a estilos=()
i=1
while (( i <= num_pages )); do
    if (( i % 3 == 1 )); then
        # Grupo de una página (estilo1)
        grupos+=("$i")
        estilos+=("estilo1")
        ((i++))
    else
        # Grupo de dos páginas (estilo2)
        if (( i+1 <= num_pages )); then
            grupos+=("$i,$((i+1))")
            estilos+=("estilo2")
            ((i+=2))
        else
            grupos+=("$i")
            estilos+=("estilo2")
            ((i++))
        fi
    fi
done

total_grupos=${#grupos[@]}
processed_grupos=0

echo "Procesando grupos de páginas:"

declare -a processed_pdfs=()

for index in "${!grupos[@]}"; do
    group="${grupos[$index]}"
    estilo="${estilos[$index]}"

    # Definir márgenes según el estilo
    if [[ "$estilo" == "estilo1" ]]; then
        margins="$margins_estilo1"
    else
        margins="$margins_estilo2"
    fi

    # Extraer el grupo de páginas
    group_pdf="$temp_dir/group_$((index+1)).pdf"
    qpdf "$temp_pdf" --pages "$temp_pdf" "$group" -- "$group_pdf" &>/dev/null || error_exit "No se pudo extraer el grupo de páginas '$group'."

    # Recortar el grupo de páginas
    cropped_group_pdf="$temp_dir/group_${index}_cropped.pdf"
    pdfcrop --margins "$margins" "$group_pdf" "$cropped_group_pdf" >/dev/null 2>&1 || error_exit "No se pudo recortar el grupo de páginas '$group'."

    # Escalar el grupo de páginas
    scaled_group_pdf="$temp_dir/group_${index}_scaled.pdf"
    pdfjam "$cropped_group_pdf" --outfile "$scaled_group_pdf" --scale 1 --paper a4paper --fitpaper true --quiet >/dev/null 2>&1 || error_exit "No se pudo escalar el grupo de páginas '$group'."

    # Añadir al array de PDFs procesados
    processed_pdfs+=("$scaled_group_pdf")

    # Actualizar la barra de progreso
    ((processed_grupos++))
    completed=$(( processed_grupos * progress_bar_length / total_grupos ))
    bar=""
    for ((j=0; j<completed; j++)); do bar+="#"; done
    for ((j=completed; j<progress_bar_length; j++)); do bar+="."; done
    echo -ne "[${bar}] ($processed_grupos/$total_grupos)\r"
done

echo ""  # Nueva línea después de la barra de progreso

# Combinar todos los grupos procesados en el orden original
combined_temp_pdf="$temp_dir/combined_temp.pdf"
qpdf --empty --pages "${processed_pdfs[@]}" -- "$combined_temp_pdf" &>/dev/null || error_exit "No se pudo combinar los grupos procesados."

# Escalado final del PDF
pdfjam "$combined_temp_pdf" --outfile "$output_pdf" --scale 0.99 --quiet >/dev/null 2>&1 || error_exit "No se pudo crear el archivo final '$output_pdf'."

# Limpieza de archivos temporales (redundante debido al trap, pero se incluye por seguridad)
rm -rf "$temp_dir" "$temp_pdf" 2>/dev/null

echo -e "\nProceso completado.\nArchivo generado: '$output_pdf'"

# Abrir el PDF si es posible
if command -v xdg-open &>/dev/null; then
    xdg-open "$output_pdf" &>/dev/null
elif command -v open &>/dev/null; then
    open "$output_pdf" &>/dev/null
fi
