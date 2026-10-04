#==================================================================#

.data
	.align 2
    Matrix: .zero 100

#==================================================================#

.text
main:

#Cargamos los valores para el paso de parametros
  la a0, Matrix #Direccion inicio
  li a1, 2 #M
  li a2, 2 #p
  li a3, 5 #q
  li a4, 10 #r

#Invocamos la funcion
  jal ra Integral_Matrix

#Finalizamos el programa para evitar errores
  li a7, 10
  ecall

#==================================================================#

  fx: #Funcion polinomica
  #Reservamos espacio en la pila
    addi sp, sp, -24
  
  #Almacenamos en la pila
    fsw fs0, 20(sp)
    fsw fs1, 16(sp)
    fsw fs2, 12(sp)
    fsw fs3, 8(sp)
    fsw fs4, 4(sp)
    sw ra, 0(sp)
  
  #Convertimos a flotante para operar con x y movemos a los registros fs los valores
    fcvt.s.w fs0, a0 #p
    fcvt.s.w fs1, a1 #q
    fcvt.s.w fs2, a2 #r0
    fmv.s fs3, fa0 #x
  
  #Calculamos x cuadrado (fs4)
    li a0, 2
    fmv.s fa0, fs3
    jal ra pow
    fmv.s fs4, fa0
  
  #Multiplicamos las x por sus coef y sumamos simultaneamente
    fmadd.s ft0, fs1, fs3, fs2 # q*x + r0 = r10
    fmadd.s fa0, fs0, fs4, ft0 # q*x*x + r10 = fx
  
  #Cargamos los valores almacenados en la pila
    flw fs0, 20(sp)
    flw fs1, 16(sp)
    flw fs2, 12(sp)
    flw fs3, 8(sp)
    flw fs4, 4(sp)
    lw ra, 0(sp)
  
  #Liberamos el espacio reservado al comienzo de la funcion
    addi sp, sp, 24
  
  #Terminamos la funcion
    jr ra

#==================================================================#

Compute_integral: #Funcion de la integral
  #Reservamos espacio en la pila
    addi, sp, sp, -44
  
  #Guardamos los valores en la pila
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    fsw fs0, 20(sp)
    fsw fs1, 24(sp)
    fsw fs2, 28(sp)
    fsw fs3, 32(sp)
    fsw fs4, 36(sp)
    fsw fs5, 40(sp)

  #Si N es 0, no se ejecutara la funcion y se devolvera NaN
    li t0, 0
    bne t0, a5, notNaN 
    li t0, 2143289345 #En binario coma flotante ese numero es igual a NaN
    fmv.w.x fa0, t0
    j finsuma
  
  #Sin importar el signo de N, se dara por hecho que ha de ser positivo (si es negativo el signo sera cambiado)
    notNaN:
    fcvt.s.w ft0, a5
    fabs.s ft0, ft0
    fcvt.w.s a5, ft0

    
  # Si a = b, la integral sera 0
    bne a0, a1, notzero
    fsub.s fa0, fa0, fa0 #Sin importar el registro, si lo restamos consigo mismo, el resultado sera 0 (se aplicará sin explicacion al resto)
    j finsuma
  
  #Cambiamos lo valores de los registros a a los s
	notzero:
	fcvt.s.w fs0, a0 #a (fs0)
    fcvt.s.w fs2, a1 #b (fs2)
    mv s0, a2 #p (s0)
    mv s1, a3 #q (s1)
    mv s2, a4 #r (s2)
    fcvt.s.w fs1, a5 #N (fs1)
  
  #Calculo de h (fs2)
    fsub.s fs2, fs2, fs0 # b-a
    fdiv.s fs2, fs2, fs1 # (b-a)/N = h
  
  #Creamos un contador y lo igualamos a 0, cont (fs3)
    fsub.s fs3, fs3, fs3
  
  #Creamos un sumador (fs4)
    li t0, 1
    fcvt.s.w fs4, t0
  
  #Y donde almacenaremos la suma de los valores de fx (fs5)
    fsub.s fs5, fs5, fs5
  
  #Creamos un 'true' para comparar con la condicion del bucle (s3)
  	li s3, 1

  #Comenzamos el bucle
    suma:
      feq.s t0, fs1, fs3
      beq t0, s3, finsuma
    
    #Llamada a fx
      #Colocamos los valores para el correcto paso de parametros
        mv a0, s0 #p
        mv a1, s1 #q
        mv a2, s2 #r
      
      #Calculamos el valor de x
        fmadd.s fa0, fs2, fs3, fs0
      
      #Invocamos la funcion y recuperamos el valor
        jal ra fx # (p,q,r == int; x = float)
        fadd.s fs5, fs5, fa0 #Suma de los terminos
    
    #Sumamos uno al contador
      fadd.s fs3, fs3, fs4
    
    #Y repetimos el bucle de nuevo
      j suma

  finsuma:
  # Multiplicamos el sumador por h para obtener el valor de la integral y lo almacenamos en fa0, para devolverlo.
    fmul.s fa0, fs2, fs5
  
  #Restauramos los valores de los registros s.
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    flw fs0, 20(sp)
    flw fs1, 24(sp)
    flw fs2, 28(sp)
    flw fs3, 32(sp)
    flw fs4, 36(sp)
    flw fs5, 40(sp)
  
  #Liberamos el espacio reservado de la pila
    addi sp, sp, 44
  
  #Finalizamos la subrutina
    jr ra

#==================================================================#

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