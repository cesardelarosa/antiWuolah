# AntiWuolah: Script para procesar PDFs

## Descripción
Este script está diseñado para procesar PDFs provenientes de Wuolah, eliminando la publicidad y ajustando el contenido para una mejor usabilidad y legibilidad.

### Funcionalidades:
- **Exclusión de páginas**: Elimina la primera, la última, y las páginas 4 y 5.
- **Recorte de páginas**: Aplica diferentes márgenes dependiendo del posicionamiento típico de publicidad de Wuolah.
- **Escalado**: Escala las páginas recortadas al tamaño A4 con factores de escalado personalizados.
- **Combinación**: Combina todas las páginas procesadas en un único PDF de salida.

---

## Requisitos
El script utiliza las siguientes herramientas. Asegúrate de que estén instaladas en tu sistema:

1. **qpdf**: Para manipular y combinar páginas de PDFs.
2. **pdfcrop**: Para recortar páginas (parte de TeX Live).
3. **pdfjam**: Para escalar páginas y ajustar el tamaño al formato A4.

Más abajo se indica como instalarlas.

---

## Uso

1. **Clonar o copiar el script**: Guarda el archivo `antiWuolah.sh` en tu directorio de trabajo.
   ```bash
   git clone https://github.com/cesardelarosa/antiWuolah.git && cd antiWuolah
   ```

2. **Dar permisos de ejecución al script** (en sistemas tipo UNIX como Linux o macOS):
   ```bash
   chmod +x antiWuolah.sh
   ```

3. **Ejecutar el script**
   ```bash
   ./antiWuolah.sh <nombre_del_pdf>
   ```
---
## Instalación de dependencias

### Linux
Para instalar las dependencias en diferentes distribuciones de Linux:

1. **Arch Linux**:
   ```bash
   sudo pacman -S qpdf texlive-bin texlive-core
   ```

2. **Debian/Ubuntu**:
   ```bash
   sudo apt install qpdf texlive-extra-utils
   ```

3. **Fedora**:
   ```bash
   sudo dnf install qpdf texlive-utils texlive-pdfjam
   ```


### macOS
1. Instala **Homebrew** si no lo tienes:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Instala las herramientas necesarias:
   ```bash
   brew install qpdf texlive
   ```

### Windows
1. Descarga e instala las dependencias manualmente:
   - **qpdf**: [Descargar desde GitHub](https://github.com/qpdf/qpdf/releases).
   - **MiKTeX**: [Descargar desde MiKTeX](https://miktex.org/download), que incluye `pdfcrop` y `pdfjam`.

2. Asegúrate de que las herramientas estén disponibles desde la línea de comandos.

3. Alternativamente, y quizá algo más sencillo, usa [**WSL (Windows Subsystem for Linux)**](https://learn.microsoft.com/es-es/windows/wsl/install) y sigue los pasos para Linux.

---
## Personalización

### Cambiar los márgenes de recorte
Los márgenes de recorte se definen en las variables:
```bash
margins_multiples_of_3="-75 -110 0 -10"  # Para páginas múltiplos de 3
margins_others="-10 0 -25 -38.5"        # Para otras páginas
```
- Formato: `left top right bottom` (en puntos; 1 punto = 1/72 pulgadas).

### Cambiar los factores de escalado
Los factores de escalado se definen en las variables:
```bash
scale_multiples_of_3=1.2  # Escalado para páginas múltiplos de 3
scale_others=1.15         # Escalado para otras páginas
```
- Valores mayores que 1 aumentan el tamaño; valores menores que 1 lo reducen.

### Cambiar las páginas eliminadas
Las páginas a eliminar se indican en:
```bash
exclude_pages=(1 $num_pages 4 5)
```

### Mayor control de "tipos de página"
Wuolah actualmente tiene 2 plantillas para meter publicidad y se van alternando en el pdf generado, este script se adapta a esa configuración, pero si esta plantilla cambia el script deja de ser útil. Aún así puedes modificar la lógica del script incluyendo más tipos de páginas con otras variables `margin` y `scale` y un cambio en la lógica del bucle while.

---

## Depuración
Si algo no funciona como se espera, puedes revisar la salida del script o depurar manualmente:

1. **Verificar las herramientas instaladas**:
   ```bash
   qpdf --version
   pdfcrop --version
   pdfjam --version
   ```

2. **Imprimir páginas procesadas**:
   Activa la depuración en el script para ver las páginas a incluir y los pasos ejecutados.

---

Disfruta del procesamiento eficiente de tus PDFs con AntiWuolah. 🚀

