# How can you use this template?
## How to clone 
```
git clone https://github.com/MetuMortis-code/KotlinSpigotPluginTemplate.git
```
## How to use
> Configure project/src/main/resources/plugin.yml.  
> Set version, name, main, api-version and do more if you want.  
> You should run ./gradlew shadowJar to get usable jar.  

# Why Kotlin?
## Which is in Java but better in Kotlin
> [Kotlin has tons of builtin methods while you are using an array you don't have to use stream library like in java.](https://kotlinlang.org/api/latest/jvm/stdlib/kotlin/-array/)
```kt
val array = arrayOf(1, 2, 3, 4, 5)
val sum = array.sum()
val first = array.first()
val last = array.last()
val biggest = array.maxOrNull()
```
> [You don't have to create separate getter and setter methods for fields](https://kotlinlang.org/docs/properties.html#getters-and-setters)
```kt
var name = "John"
    get() = field.toUpperCase()
    set(value) {
        field = value.toLowerCase()
    }
```
> [You can use any Java library or api written in Java in Kotlin](https://kotlinlang.org/docs/java-interop.html)
```kt
import java.util.*
fun main(args: Array<String>) {
    val scanner = Scanner(System.`in`)
    print("Enter your name: ")
    val name = scanner.nextLine()
    println("Name is: $name")
    scanner.close()
}
```

## What does Java doesn't have but Kotlin does have?
> [Kotlin has string templates.](https://kotlinlang.org/docs/basic-syntax.html#string-templates)
```kt
val name = "John"
println("Hello, $name")
```
> [Kotlin has null safety, safe calls, elvis operator.](https://kotlinlang.org/docs/java-interop.html#null-safety-and-platform-types)
```kt
val nullableName: String? = null
val nameLength: Int = name?.length ?: -1
println(length)
```
> [Kotlin has data classes.](https://kotlinlang.org/docs/data-classes.html)
```kt
data class Person(val name: String, val age: Int)
val John = Person("John", 30)
val anotherJohn = Person("John", 30)
println(John.equals(anotherJohn))
```
> [Kotlin has keyword arguments like in Python.](https://kotlinlang.org/docs/functions.html#named-arguments)
```kt
fun sayHi(name: String = "No one", age: Integer) = println("Hi, $name, you are $age years old")
sayHi(age = 30)
``` 
> [Kotlin has ranges like in Python.](https://kotlinlang.org/docs/functions.html#named-arguments)
```kt
println(5 in 1..10)
for(i in 1..10) {
    println(i)
}
```
> [Kotlin has operator overloading.](https://kotlinlang.org/docs/operator-overloading.html)
```kt
data class Point(val x: Int, val y: Int)
operator fun Point.unaryMinus() = Point(-x, -y)
val point = Point(10, 20)
fun main() {
   println(-point)  // prints "Point(x=-10, y=-20)"
}
```
> [Kotlin has infix functions.](https://kotlinlang.org/docs/functions.html#infix-notation)
```kt
infix fun Int.powerOf(n: Int): Int {
    return this.pow(n)
}
println(2 powerOf 3)
```
> [Kotlin has extension functions.](https://kotlinlang.org/docs/extensions.html#extension-functions)
```kt
fun MutableList<Int>.swap(index1: Int, index2: Int) {
    val tmp = this[index1] // 'this' corresponds to the list
    this[index1] = this[index2]
    this[index2] = tmp
}
val list = mutableListOf(1, 2, 3)
list.swap(0, 2) // 'this' inside 'swap()' will hold the value of 'list'
```
> [Kotlin has objects that don’t have any nontrivial supertypes.](https://kotlinlang.org/docs/object-declarations.html#creating-anonymous-objects-from-scratch)
```kt
val person = object {
    val name = "John"
    val age = 30
}
println(person.name)
```
> [Kotlin has destructuring declarations.](https://kotlinlang.org/docs/destructuring-declarations.html)
```kt
data class Person(val name: String, val age: Int)
val (name, age) = Person("John", 30)
```
> [Kotlin has scope functions.](https://kotlinlang.org/docs/scope-functions.html)
```kt
data class Person(var name: String, var age: Int = 0, var city: String = "")
val adam = Person("Adam").apply {
    age = 32
    city = "London"        
}
println(adam) // Person(name=Adam, age=32, city=London)
```
> [Kotlin has smart casts.](https://kotlinlang.org/docs/typecasts.html#smart-casts)
```kt
fun getStringLength(obj: Any): Int? {
    if (obj is String) {
        return obj.length
    }
    return null
}
```
[![Kotlin](	https://kotlinlang.org/assets/images/index/banners/kotlin-1.7.0.png)](https://kotlinlang.org/docs/comparison-to-java.html)
# Why Gradle?
> I used Gradle because scripting with Gradle using Kotlin is a lot easier than Maven
> * [Another reason](https://gradle.org/maven-vs-gradle/)
> * [Another reason](https://discuss.kotlinlang.org/t/whats-the-recommended-build-tool-to-use-with-kotlin-maven-or-gradle/3873)
> * [Another reason](https://www.reddit.com/r/Kotlin/comments/b0ykm7/maven/)
> * [Another reason](https://sendoh-daten.medium.com/how-and-why-do-i-switch-from-maven-to-gradle-b86ffefbae38)
> * [Another reason](https://www.geeksforgeeks.org/difference-between-gradle-and-maven/)

[![Gradle](https://miro.medium.com/max/1024/1*EOdsCmvfHf37LvjpBAz5rg.png)](https://gradle.org/maven-vs-gradle/)

