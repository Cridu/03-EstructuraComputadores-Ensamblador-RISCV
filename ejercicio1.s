#==================================================================#

.text
f:
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

Compute_Integral:
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
    fsub.s fa0, fa0, fa0 #Sin importar el registro, si lo restamos consigo mismo, el resultado sera 0 (se aplicarÃ¡ sin explicacion al resto)
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
        jal ra f # (p,q,r == int; x = float)
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