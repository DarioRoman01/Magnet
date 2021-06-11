# Magnet
Magnet is high level programming lenguage inspired in rust but without static typing.

syntax examples:
```dart
@a = 3;
@b = 5;
@c = a + b;
show(c); // prints 8
```

```dart
@findMax = (array) => {
    @max = 0;
    for(i in array) {
        if (i > max) {
            max = i
        }
    }

    return max;
}

@list = [2,4,32,54,2];
@result = findMax(list);
show(result); // output: 54
```

```dart
@list = [2,3,4];
list::append(10); // add 10 to the list

show(list) // output: [2, 3, 4, 10]

list::pop(); // remove the last item

list::removeAt(0); // remove element by index

list::contains(2); // check if the array contains the given value
```

```dart
@ages = map{
    "jason": 23,
    "trevor": 30,
    "peter": 34,
}

ages::get("peter");

ages::keys();

ages::values();
```


