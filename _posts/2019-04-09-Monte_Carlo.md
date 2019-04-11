---
title: "Monte Carlo"
date: "9/4/2019"
output: html_document
mathjax: "true"
---



> "It has long been an axiom of mine that the little things are infinitely
the most important." Arthur Conan Doyle

![center](/figs/2019-04-09-Monte_Carlo/unnamed-chunk-135-1.png)



### ¿ En qué consiste los métodos de Monte Carlo ?

El nombre del método no proviene de un autor como estamos acostumbrados en el mundo de la estadística, sino de un casino en Mónaco, y puntualmente le dieron este titulo debido a que los juegos de azar que son *generadores de número aleatorios*, como los resultados de las cartas, la ruletas y demás.

De la mano con lo anterior y conforme al desarrollo de la computación, durante la Segunda Guerra Mundial (1944), se estudiaba problemas probabilisticos sobre la difusión de neutrones en hidrodinámicas donde la difusión posee un comportamiento plenamente aleatorio, por lo anterior sumado al  trabajo de [Neumann](https://es.wikipedia.org/wiki/John_von_Neumann) y [Metropolis](https://es.wikipedia.org/wiki/Nicholas_Metropolis) se logro estimar valores propios en la ecuación de Schrödinge a través de este método de simulación, esta simulación basada en Monte Carlo, dando como resultado que dadas $N$ muestras en un espacio de $M$ dimesiones se puede dar un resultado (o vectores resultantes) a pesar que el problema sea deterministico o estocástico.

Lo anterior hace refiega en un concepto claro sobre los limites en la inferencia estadística, los límites sobre los problemas númericos, los cuales se presentan en dos casos:

* Problemas de optimización ;
* Problemas de integración.

Dichos problemas se presentan dado que no es posible calcular analíticamente los estimadores propios a un número de paradigmas. 

Dicho lo anterior, los mejores resultados para estos problemas vienen dados de generar simulaciones sustitutivas (de distribuciones o vectores), para calcular cantidades de interés, dado que se puede producir infinitos números de aleatorios acordes a una distribución que viene dada de un fenómeno frecuentista o asintóticos, lo cual resulta más facil que la inferencia númerica, puesto que se puede obtener y controlar el tamaño de las muestras. Y usando los resultados probabilisticos a la ley de los grandes números o teoría del limite central, se puede evidenciar como convergen los métodos de simulación y así poder dar conclusiones sobre las observaciones.


Considere lo siguiente: Dada una variable aleatoria $X$, con función de densidad $f(x)$, se evalua la expresión 

$$
\int_{x} h(x) f(x) dx
$$

Podría ser evaluada a través del método de Simpson, pero el área no se podría tratar con límites infinitos ó se puede evaluar a través de la generación de muestras $x_{1},...,x_{n}$ dada $f(x)$ y se aproxima a través de $\hat h_{n}=\frac{1}{n}\sum^{n}_{i=1} h(x_{i})$ (en otras palabras , promedio de los valores).




Lo anterior se valida a través de la convergencia que viene dada por 

$$
\hat h_n =\frac{1}{n} \sum_{n}^{i=1} h(x_i) \rightarrow  \int_{x} h(x)  f(x) dx= \mathbf{E}_f [h(X)]
$$


Lo anterior se puede demostrar al calcular $\Gamma (\lambda)$ de la siguiente expresión, gracias a la ley de los grandes números que expresa que a una sucesión infinita de variables aleatorias independientes e identicamente distribuidas que cumplen que $E(|x|< \infty)$ tiene un valor esperado en $\mu$ por lo cual el promedio de las variables aleatorias converge a $\mu$

$$
P(\lim_{n \rightarrow \infty} \hat{X}_n =\mu)=1
$$

Evaluando la expresión 

$$
\int_{0}^{\infty} x^{\lambda-1} exp(-x) dx
$$


El resultado es el siguiente

![center](/figs/2019-04-09-Monte_Carlo/unnamed-chunk-137-1.png)

Se puede evidenciar que no hay discrepancia en los valores pequeños de $\lambda$.

Más lo anrterior tiene un problema y es que la integración falla a la hora de detectar el área de importancia de la función. Por lo tanto los métodos de simulación se enfocan en esta región explotando la información de la función de densiada asociada a la integral.

*Observación:* La función de integración puede aceptar ínfinitos límites, pero sus salidas no son confiables.


Consideremos el siguiente caso: Tengo una muestra de 15 elementos proveniente de una distribución Cauchy (la de la resonancia forzada) con parámetro de localización $\theta =500$. La psuedo-muestra margial del plano es 

$$
m(x)=\int_{-\infty}^{\infty} \prod^{15}_{i=1} \frac{1}{\pi} \frac{1}{1+(x_i - \theta)^2}d\theta
$$

Manteniendo la tesis que reza en la observación se puede ver que el valor que devuelve el resultado tiende a ser incorrecto







{% highlight r %}
integrate(lik,200,500) #función programada
{% endhighlight %}



{% highlight text %}
## 1.658516e-18 with absolute error < 3.3e-18
{% endhighlight %}


Para evitar dicho problema del error , se recurre a Monte Carlo, donde el problema generico es sobre la evaluación de 

$$
\mathbf{E}_{f}[h(X)] \int_{x} h(x) f(x)
$$


Donde x denota los valores de la variable aleatoria de X que son usuales o soportables (support) para la función de densidad $f(x)$, por lo tanto el principio teórico  de Monte Carlo está dado a la aproximación de la anterior función generando muestras dada la función de densidad y aproximaciones empiricas antes mencionada

$$
\hat{h}_n = \frac{1}{n} \sum_{n}^{i=1} h(x_i)
$$

Puesto que $h_n$ converge en $\mathbf{E}_{f}[h(X)]$ por la ley de los grandes números $P(\lim_{n \rightarrow \infty} \hat{X}_n =\mu)=1$

A demás cuando $h^2(x)$ tiene una expectativa finita sobre la función de densidad, la velocidad de convergencia en $h_n$ asciende a $O \sqrt(n)$ y la varianza asintótica se aproxima a la siguiente expresión 


$$
var(\hat{h}_n)=\frac{1}{n} \int_n (h(x)-\mathbf{E}_f [h(X)])^2 f(x) dx
$$

La cual también se puede estimar a través de la muestra de 

$$
v_n=\frac{1}{n^2} \sum_{i=1}^{n}[h(x_i)-\hat{h}_n]^2
$$

Se contruye el intervalo de confianza.

Esto gracias al teorema del limite central para números grandes, donde sea $X_1,X_2,...,X_n$  un conjunto de valores independientes e identicamente distribuidos con promedio $\mu$ y varianza $0<\theta^2<\infty$, se obtiene   que

$$
\hat{X_n}=\frac{1}{n}(X_1+....+X_n-1,+X_n)
$$

Entonces 

$$
\lim_{n\rightarrow \infty} Pr(\frac{\hat{X_n}-\mu)}{\theta \sqrt} \leq z) \mbox{~ Normal(0,1)} 
$$


Lo que quiere decir que   converge $\hat{h_n}$ en $E(h(x))$

$$
\frac{\hat{h_n}-E(h(x))}{\sqrt{v_n}} \mbox{~ N(0,1)} 
$$


Dicho lo anterior se calcula $h(x)=[\cos(40x)+\sin(30x)]^2$, en donde se generaran muestras independientes e identicamente distribuidas al rededor $\int h(x)dx$ con $\h(U_i)/n$ donde $U_i$ son variables aleatorias



{% highlight text %}
## 0.8176594 with absolute error < 5.4e-05
{% endhighlight %}

![center](/figs/2019-04-09-Monte_Carlo/unnamed-chunk-140-1.png)
![center](/figs/2019-04-09-Monte_Carlo/unnamed-chunk-141-1.png)

Otra fomra de verlo es la siguiente

Suponga que hay que integrar la función 

$$
h(x)=(\cos(10x)+0.6 \sin(4x))^4
$$

En el intervalo (-1,2)


{% highlight r %}
a<-0;
b<-1;
h1<- function (x) (cos(10 * x) + 0.6 *sin(4*x))^4;
n<-1000
u<-runif(n,a,b)
mean(h(u))* (b-a)
{% endhighlight %}



{% highlight text %}
## [1] 0.8601888
{% endhighlight %}

Al desarrollar la integral observese que 


{% highlight r %}
integrate(h1,a,b)
{% endhighlight %}



{% highlight text %}
## 0.9410708 with absolute error < 6.6e-06
{% endhighlight %}

Al gráficar se obtiene que 
![center](/figs/2019-04-09-Monte_Carlo/unnamed-chunk-144-1.png)

Ahora se evidencia la eficiencia de Monte Carlo a medida que aumenta el tamaño de la población $n$ junto a los intervalos de confianza


{% highlight r %}
n_max=10^3
x<-h1(runif(n_max,a,b))
h_bar<-cumsum(x)/(1:n_max)
se<-sqrt((cumsum(x-h_bar)^2))/(1:n_max)
plot(h_bar, type = "l")
lines(h_bar+1.96*se, col="green")
lines(h_bar-1.96*se, col="red")
{% endhighlight %}

![center](/figs/2019-04-09-Monte_Carlo/unnamed-chunk-145-1.png)

Observese que las integrales pueden usarse desde que $n>500$



{% highlight r %}
n_sim<-100
n<-500
h_bar_mc<-NULL


for(i in 1:n_sim){
  x<-h1(runif(n,a,b))
  h_bar_mc[i]<-mean(x)
}

mean(h_bar_mc)
{% endhighlight %}



{% highlight text %}
## [1] 0.9411604
{% endhighlight %}



{% highlight r %}
h_bar_mc
{% endhighlight %}



{% highlight text %}
##   [1] 0.9222618 0.9880330 0.9508817 0.9720732 0.9082570 0.9860626 0.9502883
##   [8] 0.8824401 0.8492985 0.9944643 0.9241766 0.9490846 0.9211495 0.9977947
##  [15] 0.9187368 0.9524478 0.9516542 0.9647462 0.9779846 0.8216037 0.8926341
##  [22] 0.9312937 0.9262978 0.9438039 1.0340786 0.9170002 0.9107681 0.8627193
##  [29] 0.9538731 0.8825741 0.9150335 0.9142928 0.8617979 0.8767957 0.9124670
##  [36] 1.0579057 0.9568132 0.9564701 0.8690445 0.8874809 1.0209695 1.0293994
##  [43] 0.9156567 0.9781232 0.8560105 0.9453942 0.8729050 0.9471204 0.9603252
##  [50] 0.9328127 1.0340971 0.8798936 0.9657333 0.9220628 1.0017323 0.9242631
##  [57] 0.8689404 1.0010200 0.9511789 0.9926268 0.9232509 0.8939326 0.9786742
##  [64] 0.9495001 0.9744776 0.9801018 0.9381977 0.9156707 0.9965582 1.0017589
##  [71] 0.9394239 0.9250338 0.9691803 1.0209512 0.9343181 0.9054994 0.9420197
##  [78] 0.9622646 0.8547147 0.9011859 0.8357365 1.0028088 0.9704135 0.9402502
##  [85] 0.9634966 0.9486734 0.8721996 0.9536821 0.9404823 0.9969065 0.9098827
##  [92] 1.0612120 1.0589935 0.8729445 0.9345121 1.0322189 0.8829102 0.8897175
##  [99] 0.8569822 1.0384559
{% endhighlight %}






## Bibliográfia 

* Robert C,"Introducing Monte Carlo Methods with R" (2009)
* Gutiérrez A, "Teoría Estadística" (2009)



