#==================================================================#

.text
  Integral_Matrix:
    #Reservamos espacio en la pila
      addi sp sp -36

    #Guardamos los valores en la pila
      sw ra 0(sp)
      sw s0 4(sp)
      sw s1 8(sp)
      sw s2 12(sp)
      sw s3 16(sp)
      sw s4 20(sp)
      sw s5 24(sp)
      sw s6 28(sp)
      sw s7 32(sp)

    #Movemos los valores a registros s
      mv s0 a0 #Direccion de inicio
      mv s1 a1 #M
      mv s2 a2 #p
      mv s3 a3 #q
      mv s4 a4 #r

    #Si M es 0, no se ejecutara la funcion
      li t0, 0
      bne t0, a1, nocero 
      j fin_matriz

    nocero:
    #Sin importar el signo de M, se dara por hecho que ha de ser positivo (si es negativo el signo sera cambiado)
      fcvt.s.w ft0, s1
      fabs.s ft0, ft0
      fcvt.w.s s1, ft0

    #Creamos las variables a y b (valores que indican la posicion de la matriz)
      li s5 0 #a
      li s6 0 #b

    #Hacemos el bucle de la matriz para calcular y almacenar sus valores basado en a y b
    bucle1:
      bge s5 s1 fin_matriz # Fila fuera de rango?

        bucle2:
          bge s6 s1 fin_fila # Columna fuera de rango?

          #Calculamos la direccion actual (s7)
            mul t0 s1 s5
            add t0 t0 s6
            li t1 4
            mul t0 t0 t1
            add s7 s0 t0

          #Hacemos la comparacion para ver si el valor nuevo sera 0 o el calculado de la integral
            ble s6 s5 valor_cero #If b <= a salta a valor_cero

          #En caso de a < b hacemos el paso de parametros
            mv a0 s5 #a
            mv a1 s6 #b
            mv a2 s2 #p
            mv a3 s3 #q
            mv a4 s4 #r
            li a5, 100 #N

          #Invocamos la funcion de la integral
            jal ra Compute_integral #Calculamos la integral y almacenamos en fa0
            fsw fa0 0(s7) #Lo guardamos en el segmento de datos de la matriz
            j nueva_columna #Actualizamos la columna

          #Cuando b <= a el valor es 0
            valor_cero:
            li t0 0
            fcvt.s.w ft0 t0
            fsw ft0 0(s7)

          #Saltamos a la siguiente columna
            nueva_columna:
            addi s6 s6 1 # b+= 1
            j bucle2

          #Cuando el indice de columna esta fuera de rango...
            fin_fila: 
            addi s5 s5 1 # a += 1
            li s6 0 # b = 0
            j bucle1

    fin_matriz:
    #Devolvemos los valores a su lugar de inicio
      lw ra 0(sp)
      lw s0 4(sp)
      lw s1 8(sp)
      lw s2 12(sp)
      lw s3 16(sp)
      lw s4 20(sp)
      lw s5 24(sp)
      lw s6 28(sp)
      lw s7 32(sp)

    #Liberamos el espacio de la pila
      addi sp sp 36

    #Terminamos la funcion
      jr ra

#==================================================================#