# Probabilidad y Estadística - Prácticas y exámenes parciales resueltos

Este repositorio está dedicado a la **resolución completa, paso a paso y tipografiada en LaTeX** de las guías de trabajos prácticos y de los exámenes parciales de la materia **Probabilidad y Estadística** (Escuela de Computación, Facultad de Ciencias, UCV).

El objetivo es disponer de un material de estudio riguroso, didáctico y visualmente claro, organizado en dos manuales independientes:
1. **Manual de prácticas:** guías de trabajos prácticos por unidad temática (prácticas 0 a 8).
2. **Manual de exámenes parciales:** exámenes parciales organizados cronológicamente por período o semestre lectivo, como 1-2025 o 2-2025.

Ambos sistemas son modulares y permiten compilar:
- El manual maestro completo de todas las prácticas o de todos los exámenes.
- Cualquier guía de práctica o examen parcial individual.
- Cualquier ejercicio o problema suelto.

---

## 📂 Organización del proyecto

```text
PyE/                                          # Raíz del proyecto
├── Makefile                                  # Comandos make y atajos rápidos
├── compile.sh                                # Script automatizado de compilación
├── practices.tex                             # Compilador maestro de las prácticas
├── exams.tex                                 # Compilador maestro de los exámenes parciales
├── README.md                                 # Documentación y guía de uso
├── .gitignore                                # Filtro para ignorar temporales y build/
│
├── config/                                   # Configuraciones compartidas en la raíz
│   ├── preamble.tex                          # Paquetes, márgenes, colores y estilos
│   └── macros.tex                            # Atajos matemáticos de probabilidad y estadística
│
├── practices/                                # Prácticas del curso (fijas por tema)
│   ├── practice_00_counting_probability/
│   │   ├── practice_00.tex                   # Compila solo la práctica 0
│   │   └── exercises/
│   │       └── ex_01.tex                     # Ejercicio 1 resuelto
│   └── practice_08_reliability/
│       ├── practice_08.tex                   # Compila solo la práctica 8
│       └── exercises/
│           ├── ex_01.tex                     # Ejercicio 1 resuelto
│           ├── ex_02.tex                     # Ejercicio 2 resuelto
│           └── ex_03.tex                     # Ejercicio 3 resuelto
│
├── exams/                                    # Exámenes organizados por período o semestre
│   └── 2025_2/                               # Semestre 2-2025
│       └── exam_01/
│           ├── exam_01.tex                   # Compila solo el examen 1 del 2-2025
│           └── exercises/
│               └── ex_01.tex                 # Problema 1 (plantilla para plantear)
│
├── build/                                    # Salida de compilación (generada bajo demanda)
│   ├── practices.pdf                         # Manual completo de prácticas
│   ├── exams.pdf                             # Manual completo de exámenes parciales
│   ├── practices/                            # Archivos pdf de prácticas individuales completas
│   ├── exams/                                # Archivos pdf de exámenes completos por período
│   │   ├── exam_01_2025_1.pdf
│   │   ├── exam_01_2025_2.pdf
│   │   └── ...
│   └── exercises/                            # Archivos pdf de problemas individuales
│       ├── practice_08_ex_01.pdf
│       ├── exam_01_ex_01_2025_2.pdf
│       └── ...
│
└── docs/                                     # Material original de la cátedra
    ├── books/
    ├── exams/
    ├── practices/
    └── theory/
```

---

## 🛠️ Comandos de compilación (desde la raíz `PyE/`)

### 1. Documentos maestros unificados
```bash
# Compilar todo el manual de prácticas:
make practices
# (o también con su alias: make main)
# (genera build/practices.pdf)

# Compilar todo el manual de exámenes parciales:
make exams
# O su alias en español:
make parciales
# (genera build/exams.pdf con portada e índice cronológico)
```

### 2. Prácticas y ejercicios de prácticas
```bash
# Práctica completa (ejemplo: práctica 8):
make practice P=8
# O usando el atajo rápido:
make p8
# (genera build/practices/practice_08.pdf)

# Ejercicio individual (ejemplo: práctica 8, ejercicio 1):
make exercise P=8 E=1
# O usando el atajo rápido:
make p8_e1
# (genera build/exercises/practice_08_ex_01.pdf)
```

### 3. Exámenes parciales por período o semestre
Indica el semestre con la variable `S` (admite formatos como `2025-1`, `1-2025`, `2025_1`, `2025-2`, `II-2025`, etc.) y el examen con `E`:

* **Compilar un examen parcial completo:**
  ```bash
  # Examen 1 del período 2-2025:
  make exam S=2025-2 E=1
  # Atajo rápido equivalente:
  make exam1_2025_2
  # (o también con alias: make parc1_2025_2)
  # (genera build/exams/exam_01_2025_2.pdf)
  ```

* **Compilar un problema individual de un examen:**
  ```bash
  # Problema 1 del examen 1 del período 2-2025:
  make exam S=2025-2 E=1 P=1
  # Atajo rápido equivalente:
  make exam1_e1_2025_2
  # (o también con alias: make parc1_e1_2025_2)
  # (genera build/exercises/exam_01_ex_01_2025_2.pdf)
  ```

### 4. Limpieza
```bash
make clean        # Elimina archivos auxiliares (.aux, .log, .toc), preservando los archivos pdf
make clean-all    # Elimina completamente la carpeta build/
```

---

## ✏️ Cómo agregar nuevos semestres, exámenes o problemas

1. **Agregar un nuevo problema a un examen existente:**
   * En `exams/<semestre>/exam_<XX>/exercises/`, crea `ex_<YY>.tex` (puedes duplicar `ex_01.tex`).
   * En `exam_<XX>.tex`, añade:
     ```latex
     \vspace{5mm}
     \subfile{exercises/ex_02.tex}
     ```
   * Compila el problema con `make exam1_e2_2025_2` o el examen completo con `make exam1_2025_2`.

2. **Agregar un nuevo período o semestre como 1-2026:**
   * Crea la carpeta `exams/2026_1/exam_01/exercises/`.
   * Crea `exams/2026_1/exam_01/exam_01.tex`.
   * En `exams.tex`, añade el nuevo período con su título e inclusión:
     ```latex
     \separadorSemestre{Semestre 1-2026}
     \subfile{exams/2026_1/exam_01/exam_01.tex}
     ```
   * Podrás compilarlo de inmediato con `make exam S=2026-1 E=1` o `make exam1_2026_1`.
