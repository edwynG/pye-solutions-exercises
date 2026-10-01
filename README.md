# Probabilidad y Estadística - Resolución de prácticas

Este repositorio está dedicado a la **resolución completa, paso a paso y tipografiada en LaTeX** de todas las guías de trabajos prácticos de la materia **Probabilidad y Estadística**. 

El objetivo es construir un compendio riguroso, didáctico y visualmente claro de ejercicios resueltos que sirva como material de consulta y estudio para cada una de las unidades del curso:

* **Práctica 0:** Conteo y probabilidad
* **Práctica 1:** Variables aleatorias
* **Práctica 2:** Distribuciones de variables aleatorias
* **Práctica 3:** Variables aleatorias conjuntas
* **Práctica 4:** Distribución Normal, TCL y Ley de Grandes Números
* **Práctica 5:** Intervalos de confianza
* **Práctica 6:** Pruebas de hipótesis
* **Práctica 7:** Cadenas de Markov
* **Práctica 8:** Confiabilidad

---

## 📂 Organización del proyecto

```text
PyE/                                          # Raíz del proyecto
├── Makefile                                  # Comandos make genéricos y atajos
├── compile.sh                                # Script genérico de compilación
├── main.tex                                  # Compilador maestro de todo el curso
├── README.md                                 # Documentación y guía de uso
├── .gitignore                                # Filtro para ignorar temporales y build/
│
├── config/                                   # Configuraciones compartidas en la raíz
│   ├── preamble.tex                          # Paquetes, márgenes, colores y entornos de cajas
│   └── macros.tex                            # Atajos matemáticos de probabilidad y estadística
│
├── solutions/                                # Carpeta que agrupa EXCLUSIVAMENTE las prácticas
│   ├── practice_00_counting_probability/
│   │   ├── practice_00.tex                   # Compila solo la Práctica 0
│   │   └── exercises/
│   │       └── ex_01.tex                     # Ejercicio 1 resuelto
│   ├── practice_01_random_variables/
│   ├── practice_02_distributions/
│   ├── practice_03_joint_distributions/
│   ├── practice_04_normal_clt_lln/
│   ├── practice_05_confidence_intervals/
│   ├── practice_06_hypothesis_testing/
│   ├── practice_07_markov_chains/
│   └── practice_08_reliability/
│       ├── practice_08.tex                   # Compila solo la Práctica 8
│       └── exercises/
│           ├── ex_01.tex                     # Ejercicio 1 resuelto con diagrama TikZ
│           ├── ex_02.tex                     # Ejercicio 2 resuelto (MTTF y tasas variables)
│           └── ex_03.tex                     # Ejercicio 3 resuelto (sistema de 9 componentes)
│
├── build/                                    # Carpeta de salida (generada bajo demanda)
│   ├── main.pdf                              # [Nivel 3] Todo el curso unificado (en la raíz de build/)
│   ├── practices/                            # [Nivel 2] Creada únicamente al compilar prácticas completas
│   │   ├── practice_00.pdf
│   │   ├── practice_08.pdf
│   │   └── ...
│   └── exercises/                            # [Nivel 1] Creada únicamente al compilar ejercicios individuales
│       ├── practice_08_ex_01.pdf
│       ├── practice_08_ex_02.pdf
│       └── ...
│
└── docs/                                     # Material original de la cátedra
    ├── Libros/
    ├── Practicas/
    └── Teoria/
```

---

## 🛠️ Comandos genéricos de compilación (desde la raíz `PyE/`)

No necesitas entrar a ninguna subcarpeta; todos los comandos se ejecutan desde la terminal en la raíz:

### 1. Documento unificado (todo el libro)
```bash
make main
# O también: ./compile.sh main
# Resultado en: build/main.pdf
```

### 2. Práctica completa (cualquiera de la 0 a la 8)
Reemplaza `8` por la práctica que desees:
```bash
make practice P=8
# O usando el atajo rápido:
make p8
# O también: ./compile.sh practice 8
# Resultado en: build/practices/practice_08.pdf
```

### 3. Ejercicio individual (cualquiera de cualquier práctica)
Indica la práctica (`P`) y el número de ejercicio (`E`):
```bash
make exercise P=8 E=1
# O usando los atajos rápidos (admite 'ex' o 'e', con o sin ceros):
make p8_ex01
make p8_e1
# O también: ./compile.sh exercise 8 1
# Resultado en: build/exercises/practice_08_ex_01.pdf
```

### 4. Limpieza
```bash
make clean        # Elimina .aux, .log, etc., conservando los PDFs intactos
make clean-all    # Elimina toda la carpeta build/
```

---

## 🎨 Cómo personalizar el proyecto a mano

1. **Datos personales y colores:** Edita las primeras líneas de `config/preamble.tex` para cambiar tu nombre, universidad, o la paleta de colores (`colorEnunciado`, `colorSolucion`, etc.).
2. **Nuevos atajos matemáticos:** Agrega cualquier símbolo recurrente en `config/macros.tex`.
3. **Agregar un nuevo ejercicio (ejemplo: Práctica 8, Ejercicio 4):**
   * Crea el archivo `solutions/practice_08_reliability/exercises/ex_04.tex` (puedes duplicar `ex_01.tex`).
   * En `solutions/practice_08_reliability/practice_08.tex`, añade la línea: `\subfile{exercises/ex_04.tex}`.
   * ¡Listo! Ya puedes compilarlo con `make p8_ex04` o `make p8`.
