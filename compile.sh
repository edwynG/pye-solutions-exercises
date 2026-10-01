#!/usr/bin/env bash
# ==============================================================================
# SCRIPT DE COMPILACIÓN GENÉRICO (PROBABILIDAD Y ESTADÍSTICA)
# ==============================================================================
# Este script automatiza la compilación en LaTeX para cualquier nivel:
#   1. Documento maestro unificado (main.tex) -> build/main.pdf
#   2. Cualquier práctica completa             -> build/practices/practice_XX.pdf
#   3. Cualquier ejercicio individual          -> build/exercises/practice_XX_ex_YY.pdf
#
# Todo el código fuente de las prácticas se organiza dentro de 'solutions/'.
# Todos los archivos de salida y auxiliares van a 'build/' para mantener limpias las fuentes.
# ==============================================================================

# Si ocurre algún fallo crítico, detenemos la ejecución
set -e

# ------------------------------------------------------------------------------
# 1. DEFINICIÓN DE RUTAS DEL PROYECTO
# ------------------------------------------------------------------------------
# Directorio raíz del proyecto (donde reside este script compile.sh)
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Carpeta donde se almacenan únicamente las prácticas (practice_00 a practice_08)
SOLUTIONS_DIR="$ROOT_DIR/solutions"

# Carpetas de salida para los archivos PDF generados
BUILD_DIR="$ROOT_DIR/build"
BUILD_PRACTICES="$BUILD_DIR/practices"
BUILD_EXERCISES="$BUILD_DIR/exercises"
# Nota: Las carpetas de salida se crean únicamente bajo demanda en cada función,
# evitando crear carpetas innecesarias (por ejemplo, 'practices/' al compilar solo un ejercicio).


# ------------------------------------------------------------------------------
# 2. COLORES PARA LA TERMINAL (Salida clara y legible)
# ------------------------------------------------------------------------------
VERDE="\033[1;32m"
AZUL="\033[1;34m"
ROJO="\033[1;31m"
AMARILLO="\033[1;33m"
RESET="\033[0m"

# Función de ayuda que muestra cómo usar el script
mostrar_ayuda() {
    echo -e "${AZUL}======================================================================${RESET}"
    echo -e "${AZUL}GUÍA DE COMANDOS DE COMPILACIÓN (PyE)${RESET}"
    echo -e "${AZUL}======================================================================${RESET}"
    echo "1. Documento maestro (todas las prácticas unificadas):"
    echo "   ./compile.sh                          -> Compila build/main.pdf"
    echo "   ./compile.sh main                     -> Compila build/main.pdf"
    echo ""
    echo "2. Práctica completa (cualquiera de la 0 a la 8):"
    echo "   ./compile.sh practice 8               -> Compila build/practices/practice_08.pdf"
    echo "   ./compile.sh p8                       -> Atajo rápido para Práctica 8"
    echo ""
    echo "3. Ejercicio individual (cualquiera de cualquier práctica):"
    echo "   ./compile.sh exercise 8 1             -> Compila build/exercises/practice_08_ex_01.pdf"
    echo "   ./compile.sh p8_e1 (o p8_ex01)        -> Atajos rápidos para Ejercicio 1 de Práctica 8"
    echo ""
    echo "4. Limpieza:"
    echo "   ./compile.sh clean                    -> Borra archivos .log, .aux, etc. (conserva PDFs)"
    echo "   ./compile.sh clean-all                -> Elimina la carpeta build/ por completo"
    echo -e "${AZUL}======================================================================${RESET}"
}

# ------------------------------------------------------------------------------
# 3. FUNCIÓN: COMPILAR DOCUMENTO MAESTRO (main.tex)
# ------------------------------------------------------------------------------
compilar_main() {
    echo -e "${AZUL}Compilando documento maestro (main.tex)...${RESET}"
    mkdir -p "$BUILD_DIR"
    cd "$ROOT_DIR"

    # Primera pasada de compilación
    if ! pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" main.tex > /tmp/pdflatex_main.log 2>&1; then
        echo -e "${ROJO}Error en la compilación de main.tex. Detalle del log:${RESET}"
        tail -n 25 /tmp/pdflatex_main.log
        exit 1
    fi

    # Segunda pasada para resolver índices y referencias cruzadas
    pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" main.tex > /dev/null 2>&1
    # Limpiamos carpetas vacías creadas por pdflatex al procesar rutas relativas (\input y \subfile)
    find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    echo -e "${VERDE}✓ Compilación exitosa:${RESET} $BUILD_DIR/main.pdf"
}

# ------------------------------------------------------------------------------
# 4. FUNCIÓN: COMPILAR CUALQUIER PRÁCTICA (solutions/practice_XX_...)
# ------------------------------------------------------------------------------
compilar_practica() {
    # Convertimos a base decimal para evitar errores con ceros a la izquierda (ej: 08)
    local raw_p="$1"
    local p_dec=$((10#$raw_p))
    local num=$(printf "%02d" "$p_dec")

    # Localizamos la carpeta correspondiente dentro de 'solutions/'
    local carpeta=$(find "$SOLUTIONS_DIR" -maxdepth 1 -type d -name "practice_${num}_*" | head -n 1)

    if [ -z "$carpeta" ]; then
        echo -e "${ROJO}Error: No se encontró la carpeta para la práctica ${num} en solutions/.${RESET}"
        exit 1
    fi

    local archivo="$carpeta/practice_${num}.tex"
    if [ ! -f "$archivo" ]; then
        echo -e "${ROJO}Error: No se encontró el archivo $archivo.${RESET}"
        exit 1
    fi

    echo -e "${AZUL}Compilando Práctica ${num}...${RESET}"
    mkdir -p "$BUILD_PRACTICES"
    cd "$carpeta"

    if ! pdflatex -interaction=nonstopmode -output-directory="$BUILD_PRACTICES" "practice_${num}.tex" > /tmp/pdflatex_practice.log 2>&1; then
        echo -e "${ROJO}Error al compilar la práctica ${num}. Detalle del log:${RESET}"
        tail -n 25 /tmp/pdflatex_practice.log
        exit 1
    fi
    find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    echo -e "${VERDE}✓ Práctica ${num} generada:${RESET} $BUILD_PRACTICES/practice_${num}.pdf"
}

# ------------------------------------------------------------------------------
# 5. FUNCIÓN: COMPILAR CUALQUIER EJERCICIO INDIVIDUAL
# ------------------------------------------------------------------------------
compilar_ejercicio() {
    # Convertimos los números a base 10 (admite tanto '8' como '08')
    local raw_p="$1"
    local raw_e="$2"
    local p_dec=$((10#$raw_p))
    local e_dec=$((10#$raw_e))

    local pnum=$(printf "%02d" "$p_dec")
    local enum=$(printf "%02d" "$e_dec")

    # Localizamos la carpeta de la práctica en 'solutions/'
    local carpeta=$(find "$SOLUTIONS_DIR" -maxdepth 1 -type d -name "practice_${pnum}_*" | head -n 1)

    if [ -z "$carpeta" ]; then
        echo -e "${ROJO}Error: No se encontró la práctica ${pnum} en solutions/.${RESET}"
        exit 1
    fi

    local archivo="$carpeta/exercises/ex_${enum}.tex"
    if [ ! -f "$archivo" ]; then
        echo -e "${ROJO}Error: No se encontró el ejercicio $enum en: $archivo.${RESET}"
        exit 1
    fi

    echo -e "${AZUL}Compilando Ejercicio ${enum} de la Práctica ${pnum}...${RESET}"
    mkdir -p "$BUILD_EXERCISES"
    cd "$carpeta/exercises"

    # Compilamos asignándole nombre único al PDF de salida: practice_XX_ex_YY.pdf
    if ! pdflatex -interaction=nonstopmode -output-directory="$BUILD_EXERCISES" -jobname="practice_${pnum}_ex_${enum}" "ex_${enum}.tex" > /tmp/pdflatex_ex.log 2>&1; then
        echo -e "${ROJO}Error al compilar el ejercicio ${enum}. Detalle del log:${RESET}"
        tail -n 25 /tmp/pdflatex_ex.log
        exit 1
    fi
    find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    echo -e "${VERDE}✓ Ejercicio generado:${RESET} $BUILD_EXERCISES/practice_${pnum}_ex_${enum}.pdf"
}

# ------------------------------------------------------------------------------
# 6. LIMPIEZA DE ARCHIVOS AUXILIARES
# ------------------------------------------------------------------------------
limpiar_auxiliares() {
    echo -e "${AMARILLO}Limpiando archivos auxiliares en build/...${RESET}"
    if [ -d "$BUILD_DIR" ]; then
        # Elimina archivos temporales y auxiliares de pdflatex y latexmk
        find "$BUILD_DIR" -type f \( -name "*.aux" -o -name "*.log" -o -name "*.toc" -o -name "*.out" -o -name "*.fls" -o -name "*.fdb_latexmk" -o -name "*.synctex.gz" \) -delete 2>/dev/null || true
        # Elimina carpetas espejo vacías que crea internamente pdflatex (ej: build/config/, build/solutions/)
        find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    fi
    echo -e "${VERDE}✓ Archivos auxiliares y carpetas vacías eliminados. Los PDFs se conservan intactos.${RESET}"
}

limpiar_todo() {
    echo -e "${AMARILLO}Eliminando carpeta build/...${RESET}"
    rm -rf "$BUILD_DIR"
    echo -e "${VERDE}✓ Carpeta build/ eliminada.${RESET}"
}

# ------------------------------------------------------------------------------
# 7. ENRUTADOR INTELIGENTE DE ARGUMENTOS
# Reconoce atajos automáticos: p8_ex01, p8_e1, p8_ex1, p8, etc.
# ------------------------------------------------------------------------------
# Caso A: Atajo con práctica y ejercicio (ej: p8_e1, p8_ex01, p8_1)
if [[ "$1" =~ ^p([0-9]+)[_eExX]+([0-9]+)$ ]]; then
    P="${BASH_REMATCH[1]}"
    E="${BASH_REMATCH[2]}"
    compilar_ejercicio "$P" "$E"
    exit 0
fi

# Caso B: Atajo solo con práctica (ej: p8, p08, p0)
if [[ "$1" =~ ^p([0-9]+)$ ]]; then
    P="${BASH_REMATCH[1]}"
    compilar_practica "$P"
    exit 0
fi

# Caso C: Comandos explícitos
case "$1" in
    ""|"main")
        compilar_main
        ;;
    "practice"|"p"|"practica")
        if [ -z "$2" ]; then
            echo -e "${ROJO}Falta el número de práctica. Ejemplo: ./compile.sh practice 8${RESET}"
            exit 1
        fi
        compilar_practica "$2"
        ;;
    "exercise"|"e"|"ejercicio")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo -e "${ROJO}Faltan parámetros. Ejemplo: ./compile.sh exercise 8 1${RESET}"
            exit 1
        fi
        compilar_ejercicio "$2" "$3"
        ;;
    "clean")
        limpiar_auxiliares
        ;;
    "clean-all")
        limpiar_todo
        ;;
    "help"|"-h"|"--help")
        mostrar_ayuda
        ;;
    *)
        echo -e "${ROJO}Opción no reconocida: $1${RESET}"
        mostrar_ayuda
        exit 1
        ;;
esac
