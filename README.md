# Ensamblador RISC-V — CREATOR

Estructura de Computadores — UC3M

## Descripción

Conjunto de programas en **ensamblador RISC-V (RV32IMF)** desarrollados y probados con el simulador **[CREATOR](https://creatorsim.github.io/creator/)**, que incluye tanto ejercicios de funciones matemáticas con aritmética en punto flotante como el ejercicio final de la práctica.

## Contenido

| Fichero | Descripción |
|---|---|
| `ejercicio1.s` | Función `f` que evalúa un polinomio de segundo grado `f(x) = p·x² + q·x + r0` usando aritmética en punto flotante (registros `fs`/`fa`) y llamando a la función auxiliar `pow`. |
| `ejercicio2.s` | Función `Integral_Matrix`, que calcula una matriz de valores integrando la función polinómica anterior en distintos puntos, reservando y gestionando la pila para preservar los registros `s0`-`s7`. |
| `P1_Final.s` | Programa principal (`main`) que integra las funciones anteriores: reserva una matriz en `.data`, carga los parámetros y llama a `Integral_Matrix`. |
| `pow.o` | Módulo objeto (exportado por CREATOR) con la función `pow` ya ensamblada, enlazada por los ejercicios anteriores. |

## Convenio de llamada

Los programas siguen el convenio estándar de RISC-V: uso de `a0`-`a4` para paso de parámetros, `fa0` para el resultado en punto flotante, `ra` para la dirección de retorno y `s0`-`s7`/`fs0`-`fs4` como registros preservados entre llamadas (guardados y restaurados explícitamente en la pila al inicio y fin de cada función).

## Cómo ejecutarlo

1. Abrir el simulador [CREATOR](https://creatorsim.github.io/creator/) en el navegador (arquitectura **RISC-V (RV32IMFD)**).
2. Cargar `pow.o` como librería/objeto adicional (o volver a ensamblar su código fuente si se dispone de él).
3. Cargar `P1_Final.s` como programa principal.
4. Ensamblar y ejecutar paso a paso, observando el uso de la pila y de los registros de punto flotante.

También pueden cargarse `ejercicio1.s` y `ejercicio2.s` de forma independiente para probar cada función por separado.

## Tecnologías

- Ensamblador RISC-V (RV32IMF)
- Simulador [CREATOR](https://github.com/creatorsim/creator)
