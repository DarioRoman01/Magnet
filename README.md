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
    for(i in list) {
        if (i > max) {
            max = i
        }
    }

    return max;
}

@list = [2,4,32,54,2];
@result = findMax(list);
show(result);
```

```dart
@list = [2,3,4];
list::append(10); // add 10 to the list

show(list) // output: [2, 3, 4, 10]

list::pop();

list::removeAt(0);

list::contains(2);

list::max();

list::min();
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


