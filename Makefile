# ==============================================================================
# MAKEFILE GENÉRICO PARA PROBABILIDAD Y ESTADÍSTICA
# ==============================================================================
# Este archivo permite compilar cualquier nivel del proyecto con comandos simples.
# No requiere modificar nada manualmente al agregar nuevos ejercicios o prácticas.
#
# Las fuentes de las prácticas residen dentro de la carpeta 'solutions/'.
# Los PDFs resultantes se generan organizados dentro de la carpeta 'build/'.
# ==============================================================================

.PHONY: all main practice exercise clean clean-all help

# Por defecto, al ejecutar únicamente 'make', se compila el documento maestro
all: main

# Muestra el menú didáctico de ayuda en la terminal
help:
	@bash compile.sh help

# ------------------------------------------------------------------------------
# 1. COMPILACIÓN DEL DOCUMENTO MAESTRO (TODAS LAS PRÁCTICAS UNIFICADAS)
# ------------------------------------------------------------------------------
main:
	@bash compile.sh main

# ------------------------------------------------------------------------------
# 2. COMANDOS GENÉRICOS MEDIANTE VARIABLES (P y E)
# Ejemplos de uso:
#   make practice P=8        -> Compila la Práctica 8 completa
#   make exercise P=8 E=1    -> Compila el Ejercicio 1 de la Práctica 8
# ------------------------------------------------------------------------------
practice:
	@bash compile.sh practice $(P)

exercise:
	@bash compile.sh exercise $(P) $(E)

# ------------------------------------------------------------------------------
# 3. ATAJOS RÁPIDOS GENÉRICOS (Reconoce cualquier combinación automáticamente)
# Ejemplos:
#   make p8                  -> Compila la Práctica 8
#   make p8_e1               -> Compila el Ejercicio 1 de la Práctica 8
#   make p8_ex01             -> Formato alternativo con 'ex' y ceros
#   make p0_e1               -> Compila el Ejercicio 1 de la Práctica 0
# ------------------------------------------------------------------------------
p%:
	@bash compile.sh "p$*"

# ------------------------------------------------------------------------------
# 4. LIMPIEZA DE ARCHIVOS AUXILIARES (.aux, .log, etc.)
# ------------------------------------------------------------------------------
# Conserva los archivos PDF generados y borra solo la 'basura' de compilación
clean:
	@bash compile.sh clean

# Elimina completamente la carpeta build/
clean-all:
	@bash compile.sh clean-all
