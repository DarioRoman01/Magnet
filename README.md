# Magnet
Magnet is high level programming lenguage inspired in rust but without static typing.

syntax examples:
## Variables: 
```dart
@a = 3;
@b = 5;
@c = a + b;
show(c); // prints 8
```
## Functions:
To define a functions you need to use this syntax:
```dart
@name = (param) => {
    // body
}
```

for example:
```dart
@sayHi = (name) => show("Hello " + name + "!");
```


```dart
@list = [2,3,4];
list::append(10); // add 10 to the list

show(list); // output: [2, 3, 4, 10]

list::pop(); // remove the last item

list::forEach(v => show(v));

list::removeAt(0); // remove element by index

list::contains(2); // check if the array contains the given value
```

```dart
@ages = {
    "jason": 23,
    "trevor": 30,
    "peter": 34,
}

ages["trevor"]; // output: 30
ages::containsKey("jason"); // output: true
ages::containsVal(32) // output: False
ages::keys();
ages::values();
```

```dart
@findMax = (array) => {
    @max = 0;
    for(i in array) {
        if (i > max) {
            max = i;
        }
    }

    return max;
}

@list = [2,4,32,54,2];
@result = findMax(list);
show(result); // output: 54
```

