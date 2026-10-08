# ==============================================================================
# MAKEFILE GENÉRICO PARA PROBABILIDAD Y ESTADÍSTICA
# ==============================================================================
# Este archivo permite compilar cualquier nivel del proyecto con comandos simples:
#   - Documentos maestros:
#       * make main              -> manual completo de prácticas
#       * make exams             -> manual completo de exámenes parciales
#   - Guías y exámenes completos:
#       * make practice P=8      -> práctica 8 completa
#       * make exam S=2025-1 E=1 -> examen 1 del período 1-2025
#       * make exam S=2025-2 E=1 -> examen 1 del período 2-2025
#   - Ejercicios y problemas individuales:
#       * make exercise P=8 E=1  -> ejercicio 1 de la práctica 8
#       * make exam S=2025-1 E=1 P=1 -> problema 1 del examen 1 de 2025-1
#
# Prácticas en 'practices/' y exámenes organizados por período en 'exams/'.
# Todos los archivos pdf generados se organizan dentro de la carpeta 'build/'.
# ==============================================================================

.PHONY: all practices main exams parciales practice exercise exam parcial clean clean-all help

# Por defecto, compila el manual de prácticas
all: practices

# Menú didáctico de ayuda en la terminal
help:
	@bash compile.sh help

# ------------------------------------------------------------------------------
# 1. COMPILACIÓN DE DOCUMENTOS MAESTROS (MANUALES COMPLETOS)
# ------------------------------------------------------------------------------
# Manual de todas las prácticas unificadas:
practices:
	@bash compile.sh practices

# Alias de compatibilidad:
main:
	@bash compile.sh practices

# Manual de todos los exámenes parciales unificados:
exams:
	@bash compile.sh exams

# Alias en español para el manual de exámenes:
parciales:
	@bash compile.sh exams

# ------------------------------------------------------------------------------
# 2. COMANDOS GENÉRICOS MEDIANTE VARIABLES
# Prácticas:
#   make practice P=8            -> Compila la práctica 8 completa
#   make exercise P=8 E=1        -> Compila el ejercicio 1 de la práctica 8
#
# Exámenes por período o semestre:
#   make exam S=2025-1 E=1       -> Compila el examen 1 del 1-2025
#   make exam S=2025-2 E=1       -> Compila el examen 1 del II-2025
#   make exam S=2025-1 E=1 P=1   -> Compila el problema 1 del examen 1 de 2025-1
# ------------------------------------------------------------------------------
practice:
	@bash compile.sh practice $(P)

exercise:
	@bash compile.sh exercise $(P) $(E)

exam:
	@bash compile.sh exam $(S) $(E) $(P)

# Alias en español:
parcial:
	@bash compile.sh exam $(S) $(P) $(E)

# ------------------------------------------------------------------------------
# 3. ATAJOS RÁPIDOS GENÉRICOS
# Prácticas:
#   make p8                      -> Compila la práctica 8
#   make p8_e1                   -> Compila el ejercicio 1 de la práctica 8
#
# Exámenes (admite nombres en inglés y español):
#   make exam1_2025_1            -> Examen 1 del período 1-2025
#   make exam1_e1_2025_1         -> Problema 1 del examen 1 de 2025-1
#   make parc1_2025_1            -> Alias para examen 1 del 1-2025
#   make parc1_e1_2025_1         -> Alias para problema 1 del examen 1
# ------------------------------------------------------------------------------
p%:
	@bash compile.sh "p$*"

exam%:
	@bash compile.sh "exam$*"

parc%:
	@bash compile.sh "parc$*"

parcial%:
	@bash compile.sh "parcial$*"

# ------------------------------------------------------------------------------
# 4. LIMPIEZA DE ARCHIVOS AUXILIARES (.aux, .log, etc.)
# ------------------------------------------------------------------------------
clean:
	@bash compile.sh clean

clean-all:
	@bash compile.sh clean-all
