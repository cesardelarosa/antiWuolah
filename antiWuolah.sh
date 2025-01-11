#!/bin/bash

# Comprobar si se ha pasado un argumento
if [ $# -eq 0 ]; then
    echo "Uso: $0 <nombre_del_pdf>"
    exit 1
fi

# Configuración inicial
input_pdf="$1"
output_pdf="${input_pdf%.pdf}-SinAnuncios.pdf"
temp_pdf="temp.pdf"
temp_dir=$(mktemp -d)

# Margins: (L, T, R, B)
margins_multiples_of_3="-75 -110 0 -10"
margins_others="-10 0 -25 -38.5"
scale_multiples_of_3=1.2
scale_others=1.15

# Comprobar si el archivo de entrada existe
if [ ! -f "$input_pdf" ]; then
    echo "Error: El archivo $input_pdf no existe."
    exit 1
fi

# Calcular el número total de páginas
num_pages=$(qpdf --show-npages "$input_pdf")
if [ $? -ne 0 ]; then
    echo "Error: No se pudo leer el número de páginas del archivo $input_pdf."
    exit 1
fi

# Páginas a excluir: primera, última, 4 y 5
exclude_pages=(1 $num_pages 4 5)

# Generar lista de páginas a incluir en formato de rangos con comas
pages_to_keep=""
for ((i=1; i<=num_pages; i++)); do
    if [[ ! " ${exclude_pages[@]} " =~ " $i " ]]; then
        if [ -z "$pages_to_keep" ]; then
            pages_to_keep="$i"
        else
            pages_to_keep="$pages_to_keep,$i"
        fi
    fi
done

# Comprobar si hay páginas restantes
if [ -z "$pages_to_keep" ]; then
    echo "Error: No hay páginas restantes después de excluir."
    exit 1
fi

# 1. Eliminar páginas especificadas
qpdf "$input_pdf" --pages "$input_pdf" "$pages_to_keep" -- "$temp_pdf"
if [ $? -ne 0 ]; then
    echo "Error: No se pudo crear el archivo temporal $temp_pdf."
    exit 1
fi

# 2. Recortar y escalar páginas según el tipo
output_pages=()
page_counter=1

while IFS= read -r page; do
    if ((page_counter % 3 == 1)); then
        margins=$margins_multiples_of_3
        scale_factor=$scale_multiples_of_3
    else
        margins=$margins_others
        scale_factor=$scale_others
    fi

    # Extraer la página
    qpdf "$temp_pdf" --pages "$temp_pdf" "$page_counter" -- "$temp_dir/page_$page_counter.pdf"
    if [ ! -f "$temp_dir/page_$page_counter.pdf" ]; then
        echo "Error: No se pudo extraer la página $page_counter."
        exit 1
    fi

    # Recortar la página
    pdfcrop --margins "$margins" "$temp_dir/page_$page_counter.pdf" "$temp_dir/page_${page_counter}_cropped.pdf"
    if [ $? -ne 0 ]; then
        echo "Error: No se pudo recortar la página $page_counter."
        exit 1
    fi

    # Escalar la página
    pdfjam "$temp_dir/page_${page_counter}_cropped.pdf" --outfile "$temp_dir/page_${page_counter}_scaled.pdf" --scale "$scale_factor" --paper a4paper
    if [ $? -ne 0 ]; then
        echo "Error: No se pudo escalar la página $page_counter."
        exit 1
    fi

    output_pages+=("$temp_dir/page_${page_counter}_scaled.pdf")
    ((page_counter++))
done < <(seq 1 $(qpdf --show-npages "$temp_pdf"))

# 3. Combinar las páginas recortadas y escaladas
qpdf --empty --pages "${output_pages[@]}" -- "$temp_pdf"
if [ $? -ne 0 ]; then
	echo "Error: No se pudo crear el archivo final (no escalado) $temp_pdf."
    exit 1
fi

pdfjam "$temp_pdf" --outfile "$output_pdf" --scale 0.9
if [ $? -ne 0 ]; then
    echo "Error: No se pudo crear el archivo final $output_pdf."
    exit 1
fi

# Limpiar archivos temporales
rm -r "$temp_dir" "$temp_pdf" 2>/dev/null

echo "Proceso completado. Archivo generado: $output_pdf"
