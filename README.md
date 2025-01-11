# AntiWuolah: Script para procesar PDFs

## Descripción
Este script, `antiWuolah.sh`, procesa archivos PDF eliminando páginas innecesarias, recortando y escalando las páginas restantes para ajustarlas al tamaño A4.

### Funcionalidades:
- **Exclusión de páginas**: Elimina la primera, la última, y las páginas 4 y 5.
- **Recorte de páginas**: Aplica diferentes márgenes dependiendo del posicionamiento típico de publicidad de Wuolah.
- **Escalado**: Escala las páginas recortadas al tamaño A4 con factores de escalado personalizados.
- **Combinación**: Combina todas las páginas procesadas en un único PDF de salida.

---

## Requisitos
El script utiliza las siguientes herramientas. Asegúrate de que estén instaladas en tu sistema:

### Linux
1. **qpdf**: Para manipular y combinar páginas de PDFs.
   - Instalación en distribuciones basadas en Arch:
     ```bash
     sudo pacman -S qpdf
     ```
   - Instalación en distribuciones basadas en Debian/Ubuntu:
     ```bash
     sudo apt install qpdf
     ```
   - Instalación en Fedora:
     ```bash
     sudo dnf install qpdf
     ```

2. **pdfcrop**: Para recortar páginas (parte de TeX Live).
   - Instalación en Arch Linux:
     ```bash
     sudo pacman -S texlive-bin
     ```
   - Instalación en Debian/Ubuntu:
     ```bash
     sudo apt install texlive-extra-utils
     ```
   - Instalación en Fedora:
     ```bash
     sudo dnf install texlive-utils
     ```

3. **pdfjam**: Para escalar páginas y ajustar el tamaño al formato A4.
   - Instalación en Arch Linux:
     ```bash
     sudo pacman -S texlive-core
     ```
   - Instalación en Debian/Ubuntu:
     ```bash
     sudo apt install texlive-extra-utils
     ```
   - Instalación en Fedora:
     ```bash
     sudo dnf install texlive-pdfjam
     ```

### macOS
1. Instalar **Homebrew** si no lo tienes:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Instalar las herramientas necesarias:
   ```bash
   brew install qpdf
   brew install texlive
   ```

### Windows
1. Instalar las herramientas necesarias:
   - Descarga e instala **qpdf** desde [qpdf GitHub releases](https://github.com/qpdf/qpdf/releases).
   - Instala una distribución de LaTeX como **MiKTeX** desde [MiKTeX](https://miktex.org/download).

2. Asegúrate de que las herramientas `pdfcrop` y `pdfjam` estén disponibles desde la línea de comandos.

(O símplemente usa WSL, espabila un poco)

---

## Uso

1. **Clonar o copiar el script**: Guarda el archivo `antiWuolah.sh` en tu directorio de trabajo.
   ```bash
   git clone https://github.com/cesardelarosa/antiWuolah.git
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

