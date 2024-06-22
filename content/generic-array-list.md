+++
title = 'Generic Array List'
date = 2024-06-19T19:54:58-03:00
draft = true
+++

`char*` no es suficientemente geneal porque solo sirve para 
/plain old data/.

Otra forma de hacer códgo genérico en c es usando `char*`.
`void*` porque así podemos definir una función que reciba como parámetro
un puntero genérico sin necesidad de castearlo. Si fuera, en cambio,
`char*`, entonces habría que catearlo cada vez que llamamos a la función.


El problema con usar `void*` es que entonces perdemos toda la información
del tipo. O sea, lo mismo que es por un lado una ventaja (puedo definir
una función que reciba un objeto de cualquier tipo) es una desventaja:
al poder ser de cualquier tipo no puedo asumir nada soblre él. En particular,
por ejemplo, no puedo saber su tamaño ni si es data plana o tiene algúna 
referencia (un puntero). Por este motivo, no es posible copiar los datos, ni
iterar una colección de items, por ejemplo.

Podemos entoces recurrir a las macros. 

Una de ellas, cuyo nombre nos sugiere que es un buen candidato es
`_Generic`. Con ella podríamos definir un método para cada tipo y dejar que
en tiempo estático se elija el apropiado, con toda la información tanto para
iterar, copiar y más cosas. Pero hay un problema, y es que tenemos que enumerar
todos los tipos. Podría parecer bastante razonable, ya que la lista no es tan larga,
pero dejando afuera los tipos que definamos (o nuestros usuarios). En tal caso,
no podemos definir un metodo para un tipo que va a definir nuestro usuario y del
cual no sabemos nada.

No queda otra que delegar a nuestro usuario el método para copiar un objeto que él
defina, del mismo modo en que ocurre en c++. Y este es el enfoque de qsort: usa 
`void*` y parametriza la función de comparación, que tiene que saber el tipo 
de los objetos que compara.

ycombinator dcussionabout ctl:
https://news.ycombinator.com/item?id=25576466

