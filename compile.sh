#!/usr/bin/env bash
# ==============================================================================
# SCRIPT DE COMPILACIÓN GENÉRICO (PROBABILIDAD Y ESTADÍSTICA)
# ==============================================================================
# Este script automatiza la compilación en LaTeX para cualquier nivel:
#   1. Documentos maestros unificados:
#      - main.tex       -> build/main.pdf (manual completo de prácticas)
#      - exams.tex      -> build/exams.pdf (manual completo de exámenes)
#   2. Guías y exámenes completos individuales:
#      - Práctica completa -> build/practices/practice_XX.pdf
#      - Examen completo   -> build/exams/exam_XX_SEMESTRE.pdf
#   3. Ejercicios y problemas individuales:
#      - Ejercicio de práctica -> build/exercises/practice_XX_ex_YY.pdf
#      - Problema de examen    -> build/exercises/exam_XX_ex_YY_SEMESTRE.pdf
#
# Prácticas en 'practices/' y exámenes organizados por semestre en 'exams/'.
# Archivos de salida y auxiliares en 'build/'.
# ==============================================================================

set -e

# ------------------------------------------------------------------------------
# 1. DEFINICIÓN DE RUTAS DEL PROYECTO
# ------------------------------------------------------------------------------
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRACTICES_DIR="$ROOT_DIR/practices"
EXAMS_DIR="$ROOT_DIR/exams"

BUILD_DIR="$ROOT_DIR/build"
BUILD_PRACTICES="$BUILD_DIR/practices"
BUILD_EXAMS="$BUILD_DIR/exams"
BUILD_EXERCISES="$BUILD_DIR/exercises"

# ------------------------------------------------------------------------------
# 2. COLORES PARA LA TERMINAL
# ------------------------------------------------------------------------------
VERDE="\033[1;32m"
AZUL="\033[1;34m"
ROJO="\033[1;31m"
AMARILLO="\033[1;33m"
RESET="\033[0m"

# Función de ayuda didáctica
mostrar_ayuda() {
    echo -e "${AZUL}======================================================================${RESET}"
    echo -e "${AZUL}GUÍA DE COMANDOS DE COMPILACIÓN (PyE)${RESET}"
    echo -e "${AZUL}======================================================================${RESET}"
    echo "1. Documentos maestros (manuales completos unificados):"
    echo "   ./compile.sh                          -> Compila build/practices.pdf (prácticas)"
    echo "   ./compile.sh practices (o main)       -> Compila build/practices.pdf (prácticas)"
    echo "   ./compile.sh exams                    -> Compila build/exams.pdf (exámenes)"
    echo ""
    echo "2. Prácticas y ejercicios de prácticas:"
    echo "   ./compile.sh practice 8               -> Compila build/practices/practice_08.pdf"
    echo "   ./compile.sh p8                       -> Atajo rápido para práctica 8"
    echo "   ./compile.sh exercise 8 1             -> Compila build/exercises/practice_08_ex_01.pdf"
    echo "   ./compile.sh p8_e1                    -> Atajo rápido para ejercicio 1 de práctica 8"
    echo ""
    echo "3. Exámenes organizados por período o semestre como 1-2025 o 2-2025:"
    echo "   ./compile.sh exam 2025-1 1            -> Compila examen 1 del período 1-2025"
    echo "   ./compile.sh exam 2025-2 1            -> Compila examen 1 del período 2-2025"
    echo "   ./compile.sh exam1_2025_1             -> Atajo rápido para examen 1 del 1-2025"
    echo "   ./compile.sh exam 2025-1 1 1          -> Compila problema 1 del examen 1 de 2025-1"
    echo "   ./compile.sh exam1_e1_2025_1          -> Atajo rápido para problema 1 del examen 1"
    echo ""
    echo "4. Limpieza:"
    echo "   ./compile.sh clean                    -> Borra temporales (.aux, .log, etc.) conservando pdfs"
    echo "   ./compile.sh clean-all                -> Elimina la carpeta build/ por completo"
    echo -e "${AZUL}======================================================================${RESET}"
}

# ------------------------------------------------------------------------------
# 3. RESOLUCIÓN INTELIGENTE DE SEMESTRES
# Admite: 2025-1, 1-2025, 2025_1, 1_2025, I-2025, 2025-I, 2-2025, II-2025, etc.
# ------------------------------------------------------------------------------
resolver_semestre() {
    local input="$1"

    if [ -z "$input" ]; then
        local sem_disponibles=($(find "$EXAMS_DIR" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" 2>/dev/null | sort))
        if [ ${#sem_disponibles[@]} -eq 1 ]; then
            echo "${sem_disponibles[0]}"
            return 0
        fi
        return 1
    fi

    # 1. Coincidencia directa exacta
    if [ -d "$EXAMS_DIR/$input" ]; then
        echo "$input"
        return 0
    fi

    # 2. Reemplazo de guiones por guiones bajos
    local clean="${input//-/_}"
    if [ -d "$EXAMS_DIR/$clean" ]; then
        echo "$clean"
        return 0
    fi

    # 3. Formato inverso numérico: 1_2025 -> 2025_1, 2_2025 -> 2025_2
    if [[ "$clean" =~ ^([0-9]+)_([0-9]{4})$ ]]; then
        local inv="${BASH_REMATCH[2]}_${BASH_REMATCH[1]}"
        if [ -d "$EXAMS_DIR/$inv" ]; then
            echo "$inv"
            return 0
        fi
    fi

    # 4. Formato con números romanos: I_2025 -> 2025_1, II_2025 -> 2025_2
    local clean_upper="${clean^^}"
    if [[ "$clean_upper" =~ ^I_([0-9]{4})$ ]]; then
        local inv="${BASH_REMATCH[1]}_1"
        if [ -d "$EXAMS_DIR/$inv" ]; then
            echo "$inv"
            return 0
        fi
    elif [[ "$clean_upper" =~ ^II_([0-9]{4})$ ]]; then
        local inv="${BASH_REMATCH[1]}_2"
        if [ -d "$EXAMS_DIR/$inv" ]; then
            echo "$inv"
            return 0
        fi
    fi

    # 5. Formato con romano al final: 2025_I -> 2025_1, 2025_II -> 2025_2
    if [[ "$clean_upper" =~ ^([0-9]{4})_I$ ]]; then
        local inv="${BASH_REMATCH[1]}_1"
        if [ -d "$EXAMS_DIR/$inv" ]; then
            echo "$inv"
            return 0
        fi
    elif [[ "$clean_upper" =~ ^([0-9]{4})_II$ ]]; then
        local inv="${BASH_REMATCH[1]}_2"
        if [ -d "$EXAMS_DIR/$inv" ]; then
            echo "$inv"
            return 0
        fi
    fi

    # 6. Búsqueda por subcadena
    local match=$(find "$EXAMS_DIR" -maxdepth 1 -type d -name "*${clean}*" 2>/dev/null | head -n 1)
    if [ -n "$match" ]; then
        basename "$match"
        return 0
    fi

    return 1
}

es_semestre() {
    local val="$1"
    if [[ "$val" =~ [-_] ]] || [[ "$val" =~ [0-9]{4} ]] || [[ "${val^^}" =~ ^(I|II)$ ]]; then
        return 0
    fi
    return 1
}

# ------------------------------------------------------------------------------
# 4. FUNCIONES: COMPILAR DOCUMENTOS MAESTROS (practices.tex y exams.tex)
# ------------------------------------------------------------------------------
compilar_practices() {
    echo -e "${AZUL}Compilando manual maestro de prácticas (practices.tex)...${RESET}"
    mkdir -p "$BUILD_DIR"
    cd "$ROOT_DIR"

    if ! pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" practices.tex > /tmp/pdflatex_practices.log 2>&1; then
        echo -e "${ROJO}Error en la compilación de practices.tex. Detalle del log:${RESET}"
        tail -n 25 /tmp/pdflatex_practices.log
        exit 1
    fi

    pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" practices.tex > /dev/null 2>&1
    find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    echo -e "${VERDE}✓ Compilación exitosa:${RESET} $BUILD_DIR/practices.pdf"
}

compilar_exams() {
    echo -e "${AZUL}Compilando manual maestro de exámenes (exams.tex)...${RESET}"
    mkdir -p "$BUILD_DIR"
    cd "$ROOT_DIR"

    if ! pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" exams.tex > /tmp/pdflatex_exams.log 2>&1; then
        echo -e "${ROJO}Error en la compilación de exams.tex. Detalle del log:${RESET}"
        tail -n 25 /tmp/pdflatex_exams.log
        exit 1
    fi

    pdflatex -interaction=nonstopmode -output-directory="$BUILD_DIR" exams.tex > /dev/null 2>&1
    find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    echo -e "${VERDE}✓ Compilación exitosa:${RESET} $BUILD_DIR/exams.pdf"
}

# ------------------------------------------------------------------------------
# 5. FUNCIONES: COMPILAR PRÁCTICAS Y SUS EJERCICIOS
# ------------------------------------------------------------------------------
compilar_practica() {
    local raw_p="$1"
    local p_dec=$((10#$raw_p))
    local num=$(printf "%02d" "$p_dec")

    local carpeta=$(find "$PRACTICES_DIR" -maxdepth 1 -type d -name "practice_${num}_*" 2>/dev/null | head -n 1)

    if [ -z "$carpeta" ]; then
        echo -e "${ROJO}Error: No se encontró la carpeta para la práctica ${num} en practices/.${RESET}"
        exit 1
    fi

    local archivo="$carpeta/practice_${num}.tex"
    if [ ! -f "$archivo" ]; then
        echo -e "${ROJO}Error: No se encontró el archivo $archivo.${RESET}"
        exit 1
    fi

    echo -e "${AZUL}Compilando práctica ${num}...${RESET}"
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

compilar_ejercicio() {
    local raw_p="$1"
    local raw_e="$2"
    local p_dec=$((10#$raw_p))
    local e_dec=$((10#$raw_e))

    local pnum=$(printf "%02d" "$p_dec")
    local enum=$(printf "%02d" "$e_dec")

    local carpeta=$(find "$PRACTICES_DIR" -maxdepth 1 -type d -name "practice_${pnum}_*" 2>/dev/null | head -n 1)

    if [ -z "$carpeta" ]; then
        echo -e "${ROJO}Error: No se encontró la práctica ${pnum} en practices/.${RESET}"
        exit 1
    fi

    local archivo="$carpeta/exercises/ex_${enum}.tex"
    if [ ! -f "$archivo" ]; then
        echo -e "${ROJO}Error: No se encontró el ejercicio $enum en: $archivo.${RESET}"
        exit 1
    fi

    echo -e "${AZUL}Compilando ejercicio ${enum} de la práctica ${pnum}...${RESET}"
    mkdir -p "$BUILD_EXERCISES"
    cd "$carpeta/exercises"

    if ! pdflatex -interaction=nonstopmode -output-directory="$BUILD_EXERCISES" -jobname="practice_${pnum}_ex_${enum}" "ex_${enum}.tex" > /tmp/pdflatex_ex.log 2>&1; then
        echo -e "${ROJO}Error al compilar el ejercicio ${enum}. Detalle del log:${RESET}"
        tail -n 25 /tmp/pdflatex_ex.log
        exit 1
    fi
    find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    echo -e "${VERDE}✓ Ejercicio generado:${RESET} $BUILD_EXERCISES/practice_${pnum}_ex_${enum}.pdf"
}

# ------------------------------------------------------------------------------
# 6. FUNCIONES: COMPILAR EXÁMENES Y PROBLEMAS POR SEMESTRE
# ------------------------------------------------------------------------------
buscar_carpeta_exam() {
    local sem="$1"
    local pnum="$2"
    local p_dec="$3"

    # A. Buscar en exams/<semestre>/exam_<num>
    if [ -n "$sem" ] && [ -d "$EXAMS_DIR/$sem" ]; then
        local c=$(find "$EXAMS_DIR/$sem" -maxdepth 1 -type d \( -name "exam_${pnum}" -o -name "exam_${pnum}_*" -o -name "exam_${p_dec}" -o -name "exam_${p_dec}_*" \) 2>/dev/null | head -n 1)
        if [ -n "$c" ]; then echo "$c"; return 0; fi
    fi

    # B. Buscar en exams/exam_<num>/<semestre>
    local parent_p=$(find "$EXAMS_DIR" -maxdepth 1 -type d \( -name "exam_${pnum}" -o -name "exam_${pnum}_*" -o -name "exam_${p_dec}" -o -name "exam_${p_dec}_*" \) 2>/dev/null | head -n 1)
    if [ -n "$parent_p" ] && [ -n "$sem" ]; then
        local c=$(find "$parent_p" -maxdepth 1 -type d \( -name "$sem" -o -name "*$sem*" \) 2>/dev/null | head -n 1)
        if [ -n "$c" ]; then echo "$c"; return 0; fi
    fi

    # C. Buscar en exams/ como carpeta plana (ej: exam_01_2025_1 o 2025_1_exam_01)
    if [ -n "$sem" ]; then
        local c=$(find "$EXAMS_DIR" -maxdepth 1 -type d \( -name "exam_${pnum}_${sem}*" -o -name "${sem}_exam_${pnum}*" \) 2>/dev/null | head -n 1)
        if [ -n "$c" ]; then echo "$c"; return 0; fi
    fi

    return 1
}

compilar_exam() {
    local sem_input="$1"
    local raw_p="$2"

    local sem
    if ! sem=$(resolver_semestre "$sem_input"); then
        echo -e "${ROJO}Error: Debe especificar un semestre válido (ej: 2025-1, 1-2025, II-2025).${RESET}"
        echo -e "${AMARILLO}Semestres disponibles en exams/:${RESET}"
        find "$EXAMS_DIR" -maxdepth 1 -mindepth 1 -type d -printf "  - %f\n" 2>/dev/null | sort
        exit 1
    fi

    local p_dec=$((10#$raw_p))
    local pnum=$(printf "%02d" "$p_dec")

    local carpeta
    if ! carpeta=$(buscar_carpeta_exam "$sem" "$pnum" "$p_dec"); then
        echo -e "${ROJO}Error: No se encontró el examen ${pnum} para el período ${sem} en exams/.${RESET}"
        exit 1
    fi

    local archivo="$carpeta/exam_${pnum}.tex"
    if [ ! -f "$archivo" ]; then
        archivo=$(find "$carpeta" -maxdepth 1 -name "exam_*.tex" 2>/dev/null | head -n 1)
        if [ ! -f "$archivo" ]; then
            echo -e "${ROJO}Error: No se encontró el archivo TeX del examen en $carpeta.${RESET}"
            exit 1
        fi
    fi

    local job_name="exam_${pnum}_${sem}"
    echo -e "${AZUL}Compilando examen ${pnum} (período ${sem})...${RESET}"
    mkdir -p "$BUILD_EXAMS"
    cd "$carpeta"

    local nom_archivo=$(basename "$archivo")
    if ! pdflatex -interaction=nonstopmode -output-directory="$BUILD_EXAMS" -jobname="$job_name" "$nom_archivo" > /tmp/pdflatex_exam.log 2>&1; then
        echo -e "${ROJO}Error al compilar el examen ${pnum} (${sem}). Detalle del log:${RESET}"
        tail -n 25 /tmp/pdflatex_exam.log
        exit 1
    fi
    find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    echo -e "${VERDE}✓ Examen generado:${RESET} $BUILD_EXAMS/${job_name}.pdf"
}

compilar_ejercicio_exam() {
    local sem_input="$1"
    local raw_p="$2"
    local raw_e="$3"

    local sem
    if ! sem=$(resolver_semestre "$sem_input"); then
        echo -e "${ROJO}Error: Debe especificar un semestre válido (ej: 2025-1, 1-2025, II-2025).${RESET}"
        echo -e "${AMARILLO}Semestres disponibles en exams/:${RESET}"
        find "$EXAMS_DIR" -maxdepth 1 -mindepth 1 -type d -printf "  - %f\n" 2>/dev/null | sort
        exit 1
    fi

    local p_dec=$((10#$raw_p))
    local e_dec=$((10#$raw_e))
    local pnum=$(printf "%02d" "$p_dec")
    local enum=$(printf "%02d" "$e_dec")

    local carpeta
    if ! carpeta=$(buscar_carpeta_exam "$sem" "$pnum" "$p_dec"); then
        echo -e "${ROJO}Error: No se encontró el examen ${pnum} para el período ${sem} en exams/.${RESET}"
        exit 1
    fi

    local archivo="$carpeta/exercises/ex_${enum}.tex"
    if [ ! -f "$archivo" ]; then
        archivo=$(find "$carpeta/exercises" -maxdepth 1 \( -name "ex_${enum}.tex" -o -name "ex_${e_dec}.tex" -o -name "prob_${enum}.tex" -o -name "prob_${e_dec}.tex" \) 2>/dev/null | head -n 1)
        if [ ! -f "$archivo" ]; then
            echo -e "${ROJO}Error: No se encontró el problema $enum en: $carpeta/exercises/.${RESET}"
            exit 1
        fi
    fi

    local job_name="exam_${pnum}_ex_${enum}_${sem}"
    echo -e "${AZUL}Compilando problema ${enum} del examen ${pnum} (período ${sem})...${RESET}"
    mkdir -p "$BUILD_EXERCISES"
    cd "$carpeta/exercises"

    local nom_archivo=$(basename "$archivo")
    if ! pdflatex -interaction=nonstopmode -output-directory="$BUILD_EXERCISES" -jobname="$job_name" "$nom_archivo" > /tmp/pdflatex_exam_ex.log 2>&1; then
        echo -e "${ROJO}Error al compilar el ejercicio ${enum} del examen ${pnum} (${sem}). Detalle del log:${RESET}"
        tail -n 25 /tmp/pdflatex_exam_ex.log
        exit 1
    fi
    find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    echo -e "${VERDE}✓ Ejercicio de examen generado:${RESET} $BUILD_EXERCISES/${job_name}.pdf"
}

# ------------------------------------------------------------------------------
# 7. LIMPIEZA DE ARCHIVOS AUXILIARES
# ------------------------------------------------------------------------------
limpiar_auxiliares() {
    echo -e "${AMARILLO}Limpiando archivos auxiliares en build/...${RESET}"
    if [ -d "$BUILD_DIR" ]; then
        find "$BUILD_DIR" -type f \( -name "*.aux" -o -name "*.log" -o -name "*.toc" -o -name "*.out" -o -name "*.fls" -o -name "*.fdb_latexmk" -o -name "*.synctex.gz" \) -delete 2>/dev/null || true
        find "$BUILD_DIR" -mindepth 1 -type d -empty -delete 2>/dev/null || true
    fi
    echo -e "${VERDE}✓ Archivos auxiliares y carpetas vacías eliminados. Los pdfs se conservan intactos.${RESET}"
}

limpiar_todo() {
    echo -e "${AMARILLO}Eliminando carpeta build/...${RESET}"
    rm -rf "$BUILD_DIR"
    echo -e "${VERDE}✓ Carpeta build/ eliminada.${RESET}"
}

# ------------------------------------------------------------------------------
# 8. ENRUTADOR INTELIGENTE DE ARGUMENTOS
# ------------------------------------------------------------------------------

# Caso A: Atajo para problema de examen con semestre (ej: exam1_e1_2025_1, parc1_e1_2025_1)
if [[ "$1" =~ ^(exam|parc|parcial)([0-9]+)[_]?[eExX]+([0-9]+)[_-](.+)$ ]]; then
    P="${BASH_REMATCH[2]}"
    E="${BASH_REMATCH[3]}"
    SEM="${BASH_REMATCH[4]}"
    compilar_ejercicio_exam "$SEM" "$P" "$E"
    exit 0
fi

# Caso B: Atajo para problema de examen sin semestre (ej: exam1_e1, parc1_e1)
if [[ "$1" =~ ^(exam|parc|parcial)([0-9]+)[_]?[eExX]+([0-9]+)$ ]]; then
    P="${BASH_REMATCH[2]}"
    E="${BASH_REMATCH[3]}"
    compilar_ejercicio_exam "" "$P" "$E"
    exit 0
fi

# Caso C: Atajo para examen con semestre (ej: exam1_2025_1, parc1_2025_1, exam1_2025-2)
if [[ "$1" =~ ^(exam|parc|parcial)([0-9]+)[_-](.+)$ ]]; then
    P="${BASH_REMATCH[2]}"
    SEM="${BASH_REMATCH[3]}"
    compilar_exam "$SEM" "$P"
    exit 0
fi

# Caso D: Atajo para examen sin semestre (ej: exam1, parc1)
if [[ "$1" =~ ^(exam|parc|parcial)([0-9]+)$ ]]; then
    P="${BASH_REMATCH[2]}"
    compilar_exam "" "$P"
    exit 0
fi

# Caso E: Atajo con práctica y ejercicio (ej: p8_e1, p8_ex01)
if [[ "$1" =~ ^p([0-9]+)[_]?[eExX]+([0-9]+)$ ]]; then
    P="${BASH_REMATCH[1]}"
    E="${BASH_REMATCH[2]}"
    compilar_ejercicio "$P" "$E"
    exit 0
fi

# Caso F: Atajo solo con práctica (ej: p8, p08, p0)
if [[ "$1" =~ ^p([0-9]+)$ ]]; then
    P="${BASH_REMATCH[1]}"
    compilar_practica "$P"
    exit 0
fi

# Caso G: Comandos explícitos
case "$1" in
    ""|"practices"|"main")
        compilar_practices
        ;;
    "exams"|"parciales")
        compilar_exams
        ;;
    "exam"|"parcial"|"parc")
        if [ -n "$4" ]; then
            if es_semestre "$2"; then
                compilar_ejercicio_exam "$2" "$3" "$4"
            elif es_semestre "$4"; then
                compilar_ejercicio_exam "$4" "$2" "$3"
            else
                compilar_ejercicio_exam "$2" "$3" "$4"
            fi
        elif [ -n "$3" ]; then
            if es_semestre "$2"; then
                compilar_exam "$2" "$3"
            elif es_semestre "$3"; then
                compilar_exam "$3" "$2"
            else
                compilar_ejercicio_exam "" "$2" "$3"
            fi
        elif [ -n "$2" ]; then
            if es_semestre "$2"; then
                echo -e "${ROJO}Falta el número de examen. Ejemplo: ./compile.sh exam $2 1${RESET}"
                exit 1
            else
                compilar_exam "" "$2"
            fi
        else
            echo -e "${ROJO}Faltan parámetros. Ejemplo: ./compile.sh exam 2025-1 1${RESET}"
            exit 1
        fi
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
