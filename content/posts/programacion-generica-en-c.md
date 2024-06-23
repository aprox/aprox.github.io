---
title: 'Programación genérica en C'
date: 2024-06-19T19:54:58-03:00
draft: false
---

## Generalización en general


Si bien se programa para una tarea particular (independientemente de qué
tan abstracta pueda llegar a ser esa tarea) los programadores siempre mantienen
un sentido puesto en la generalización. La tarea puede ser tan concreta como
armar una string para un log que servirá para debuggear, o abstracta como una
función aplicable a una familia de tipos. Pero en cualquier caso, el programador
busca que su código sea en la medida de lo posible lo más general, es decir,
que sea reusable en la mayor cantidad de casos.

Esto implica por un lado que el código que está escribiendo sea lo
suficientemente flexible y a la vez que todos los lugares en los que se pueda
reutilizar sean compatibles con él (esto último se puede complicar llegando a
tener que hacer un refactor de todo un repositorio o hasta un cambio en la api,
etc.).

En cuanto a lo primero, hay dos técnicas que están en juego permanentemente que
podrían llamarse _factorización_ y _parametrización_.

Supongamos por ejemplo que tenemos un código con los programas `P1` y `P2`
estructurado de la forma siguiente:


```
P1:                  |    P2:              
    bloque A1:       |        bloque A2:
        .            |            .
        .            |            .
        .            |            .
                     |    
    bloque B1:       |        bloque B2:
        .            |            .
        .            |            .
        .            |            .
                     |                     
```

Y que los bloques `A1` y `A2` son idénticos. Entonces "factorizamos" del
siguiente modo:

```
A:
    bloque A
       .
       .
       .

P1:               |    P2:              
    call A        |        call A
    bloque B1:    |        bloque B2:
        .         |            .
        .         |            .
        .         |            .
                  |                     
```

Donde `A` = `A1` = `A2`. Es decir, reemplazamos el código repetido en `P1` y
`P2` por la subrutina `A`, que pasamos a escribir una sola vez en vez de dos y
"llamarla" en ambos usos.

En general, el código repetido no es tal cual si no que tiene alguna que otra
variación. De hecho veo poco probable que un programador encuentra que ha escrito
dos veces exactamente lo mismo, por que en tal caso podría haber sacado factor
común en su cabeza directamente. Pero si ocurre que "modulo" algunas partes
variables encontramos bloques que "hacen lo mismo". Lo que hacemos entonces es
"parametrizar" eso.

Ejemplo:

```
bloque A1:          | bloque A2:
 a b c d e          |  a b f d g
```

Entonces como el tercer y quinto punto de la secuencia difieren los
parametrizamos:

```
bloque A:
 λx,y.  a b x d y

bloque A1:          | bloque A2:
 A c e              |  A f g
```

Estas operaciones son como una segunda naturaleza (en el sentido de _second
nature_) y se emplean diariamente en la programación.

Y hay un problema que es que no hay una única forma de factorización (en el
sentido de parametrizar bloques sacando al mismo tiempo factor común en
funciones), y los programadores pueden tener distintas opiniones sobre la mejor
forma de hacerlo. Pero ese puede ser un punto álgido y no me quería meter ahora.
De todo modos, el resultado suele ser descripto como:
+ menos código para escribir, revisar e introducir errores e inconsistencias,
+ menos código tambén vuelve más facil leerlo y entenderlo ("razonar acerca
  de él")
+ una función, herramienta, librería[^1], framework o lo que sea que simplifica
  o reduce el trabajo posterior.

## Tipos en C

Algunas palabras resumiendo el _standard_ de C (6.2.5) pra contextualizar el párrafo
siguiente.

Hay diez _tipos enteros estándar_: los  con signo `signed char`, `signed short`,
`signed int`, `signed long` y `signed long long` y los sin signo (`unsigned`)
correspondientes.

Hay tres tipos _float_: `float`, `double` y `long double`.

Y hay tres tipos _complejos_: `float _Complex`, `double _Complex` y `long
_Complex`.

El conjunto de los tipos enteros (con y sin signo), los floats y `char` (nótese
que `char` es distinto de `signed char` y también de `unsigned char`) recibe el
nombre de *tipos básicos* (_basic types_)

El conjunto de los typos `char`, `signed char` y `unsigned char` son los
`character types`.

Los `enums` pertenecen todos a los `enumerated types`.

Los tipos enteros (con o sin signo) junto con el tipo `char` y los tipos
enumerados se llaman tipos enteros (_integer types_), que junto a todos los
floats se llaman *tipos aritméticos* (_arithmetic types_), lo que se dividen en
los *dominios* real y complejo.

Existe el tipo `void` que no tiene valores.

Existen los tipos derivados:
+ *arreglos* (_array types_),
+ *structs* (_structure types_),
+ *unions* (_union types_),
+ *funciones* (_funcion types_),
+ *punteros* (_pointer types_, un puntero a una función es un puntero),
+ *atómicos* (_atomic types_, designados con `_Atomic`.


Los tipos aritméticos junto con los punteros reciben colectivamente el nombre de
*tipos escalares* (_scalar types_), mientras que los arreglos junto con los
structs el de *tipos agregados* (_aggregated types_).

Existen *cualificadores* para todos estos tipos mencionados (_qualifiers_), a
saber: `const`, `volatile`, `restrict`. Y también `_Atomic` es un cualifcador.

Por último, existe el tipo `void*` (puntero a *void*) que es un puntero
genérico, como veremos más adelante.

Otro concepto que se menciona en el standard es el de _objeto_ (que no tiene
nada que ver con el de objeto en el contexto de programación orientada a
objetos ni es el mismo concepto que objeto en c++) y que se define en el tercer
capítulo así:

> Region of data storage in the execution environment, the content of which can
> represent values.

Es decir que es una región de la memoria en el ambiente de ejecución cuyo
contenido puede representar valores.

Y más adelante, en *6.5.6*, se describe el *effective type* (tipo efectivo) de
un objeto

> The _effective type_ of an object for an access to its stored value is the
> declared type of the object, if any. If a value is stored into an object
> having no declared type through an lvalue having a type that is not a
> character type, then the type of the lvalue becomes the effective type of the
> object for that access and for subsequent accesses that to not modify the stored
> value. If a value is copied into an object having no declared type using 
> *memcpy* or *memmove*, or is copied as an array of character type, then the
> effective type of the modified object for that access and for subsequent
> accesses that do not modify the value is the effective type of the object from
> which is copied, if it has one. For all other access to an object having no
> declared type, the effective type of the object is simply the type of the
> lvalue used for the access.

Vemos este párrafo. En primer lugar, si tiene un tipo
declarado, el tipo efectivo de un objeto (para una acceso a un valor guardado en
él) es ese tipo declarado. Esto es bastante esperable: si yo declaro una
variable `struct foo f;` entonces el tipo del objeto designado por `f` es
`struct foo`.

Si un valor es guardado en un objeto que no tiene tipo declarado mediante un
_lvalue_ cuyo tipo no es un _character type_, entoces el tipo efectivo del
objeto para ese acceso (y todos los accesos subsiguientes que no modifiquen el
valor) será el del _lvalue_. Si no tiene un tipo declarado es porque el objeto
fue creado mediante una llamada a funciones como `malloc`, `calloc`, `realloc`,
etc. Por ejemplo: `struct foo* f = malloc(sizeof(foo));`: acá el objeto creado
por `malloc` tiene el tipo efectivo `struct foo`. Nótese que se excluye el caso
en que el _lvalue_ sea por ejemplo `char` como `char* f = malloc(sizeof(struct
foo));` 

Si un valor es copiado a un objeto sin tipo declarado usando `memcpy` o
`memmove` o copiado como un arreglo de un _character type_, entonces el tipo
efectivo  del objeto modificado para ese acceso y para los accesos subsiguientes
que no modifiquen el valor es el tipo efectivo del objeto desde el cual se
copio, si es que lo tiene. Me imagino que este caso incluye a cosas como:
```
struct foo = (struct foo){0};
memcpy(malloc(sizeof(struct foo)), &a_foo, sizeof (struct foo));
```

que no está bien igualmente porque habría que chequear primero que `malloc` no devuelva
`NULL` y guardar la dirección. Pero como se excluyen los tipos de caracteres también:

```
struct foo = (struct foo){0};
char* foo_copy = malloc(sizeof (struct foo));
if (foo) {
    memcpy(foo_copy, &a_foo, sizeof (struct foo));
}
...
```

Finalmente, para todos los otros accesos a un objeto sin tipo declarado su tipo
efectivo es simplemente el tipo del _lvalue_ usado para ese acceso.

A continuación, el standard enumera todos los casos en que se puede acceder a un
objeto mediante un alias (mediante un lvalue). Si un objeto tiene tipo efectivo `T`,
entonces puede accederse mediante:

1. un tipo compatible `T`,
2. una versión cualificada de un tipo compatible `T`,
3. la versión con (o sin) signo de `T` ,
3. la versión con (o sin) signo de `T` cualificado,
4. un _aggregate or union type_ que inclute `T` entre sus miembros,
5. un _character type_.

Cualquier otro acceso es _undefined behaviour_. Nótese que siempre podemos usar
`char*` para acceder a un objeto. Esto nos interesa en este momento porque nos
da generalidad: ya que podemos acceder a un objeto con un puntero a `char`,
puede ser una manera de definir una función aplicable para objetos de diferente
tipo.

## Programación genérica

Quizá podría decirse que toda programación es genérica y que el resto es
configuración. Pero se la asocia históricamente en forma más específica con la
[parametrización de tipos](https://en.wikipedia.org/wiki/Generic_programming). Y
ese es el tema de este post, después del rodeo de los párrafos anteriores.

Una de las estructuras de datos más comunes y que muchos lenguajes incluyen pero
C no es la de
[arreglo dinámico, o array list](https://en.wikipedia.org/wiki/Dynamic_array)

`vector` en C++,`list` en python, `ArrayList` en java y zig, `Vec` en rust son
varios ejemplos de memoria contigua que dinámicamente se puede ajustar y guarda
elementos en forma contigua. Estos tipos varían pero todos incluyen métodos para
conocer el tamaño de la colección, para leer el enésimo elemento, para insertar
y remover al final. Y también, ajustan su tamaño si es necesario para 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Tomemos por ejemplo la función de la librería standard de C `printf`[^2]:
```
int printf(const char *restrict format, ...);
```


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

[^1]: En sistmas operativos nos enseñaban que la traducción correcta de
    _library_ es _biblioteca_, pero como bien dice
    [wikipedia](https://es.wikipedia.org/wiki/Biblioteca_(inform%C3%A1tica)), el
    vicio del lenguaje (?) hace que todo el mundo diga _librería_.

[^2]: Cf. `man 3 printf`.
