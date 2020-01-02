# Flutter Bloc

## Bloc

### Bloc简介

Bloc是Business Logic Component的缩写，Bloc能够使UI层和业务逻辑分开来，能够更快的编码更加容易测试且重用性更高。Flutter仓库地址是https://pub.dev/packages/bloc，官网地址是https://bloclibrary.dev

### 核心概念

#### Events

Events事件是Bloc的输入。 通常是指用户交互的事件（例如按钮按下）或生命周期事件（例如页面加载）等。

在Flutter的计数器App中有增加计数器和减少计数器两种操作，那么我们就会定义出下面的事件:

```dart
enum CounterEvent { increment, decrement }
```

在计数器的场景下业务比较简单，使用枚举就可以满足需求。在更复杂的场景下可以使用class类来描述事件

#### States

States状态是Bloc的输出，代表应用程序状态的一部分。 可以根据当前状态来更新或部分更新UI组件。

在计数器App中一个int整数就可以表示计数器当前的状态

#### Transitions

从一种状态到另一种状态的转换称为转变（Transitions）。 转变由当前状态、事件和下一个状态组成。

当用户与计数器App交互时会除非Increment和Decrement事件，这两个事件都会更新计数器的状态。这些变化就可以描述成转变。例如当点击了增加计数器按钮我们会看到如下转变

```json
{
  "currentState": 0,
  "event": "CounterEvent.increment",
  "nextState": 1
}
```

因为*所有的状态变化都是可记录的，我们可以很容易的追踪用户的交互。同时使复现用户操作路径成为了可能*

#### Streams

流是一系列异步数据。流的概念和rxjava、rxcocoa中的概念差不多。

在dart中我们可以通过async功能创建Stream流**

```dart
Stream<int> countStream(int max) async* {
    for (int i = 0; i < max; i++) {
        yield i;
    }
}
```

通过把函数标记成async，然后通过yield关键字就可以返回一个数据流。上面的代码将返回最大为值为参数max的整数流。每一次在async*函数中通过yield,我们就将一部分数据转换成了Stream流。

我们可以通过下面的方式使用Stream流，如果我们需要写一个计算Stream整数流中所有数据的和，代码可以如下

```dart
Future<int> sumStream(Stream<int> stream) async {
    int sum = 0;
    await for (int value in stream) {
        sum += value;
    }
    return sum;
}
```

通过把函数标记成async，使用await关键字返回整数的Future。上面的代码返回了stream整数流中所有整数的和。

整体的调用代码如下

```dart
void main() async {
    /// Initialize a stream of integers 0-9
    Stream<int> stream = countStream(10);
    /// Compute the sum of the stream of integers
    int sum = await sumStream(stream);
    /// Print the sum
    print(sum); // 45
}
```

#### Blocs

Bloc业务逻辑组价是将传入的事件流转换成传出状态流的组件。

1.每个Bloc必须继承于Bloc基类，Bloc基类是核心bloc中的包，比如像下面这样

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {

}
```

上面的代码定义了CounterBloc，将CounterEvents事件转换成int状态。

2.每一个Bloc都必须定义初始的状态，该状态是在接受事件之前 状态。

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {
	@override
	int get initialState => 0;
}
```

3.每个Bloc必须重写基类的mapEventToState函数，这个函数的功能是将Event事件转换成State状态流

```dart
import 'package:bloc/bloc.dart';

class CounterBloc extends Bloc<CounterEvent, int> {
	@override
	int get initialState => 0;
	
	@override
	Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
}
}
```

整个计数器App中的Bloc逻辑基本就是上面的代码块了。需要注意的是Bloc会忽略重复的状态，如果当前状态和下一个状态是一样的，那么就不会触发转变Transition。

4.每个Bloc都有一个add方法，Add方法接受一个Event事件，并同时触发mapEventToState函数。UI层和Bloc内部都可以触发add操作，并将新的事件通知Bloc。

根据上面的步骤，我们可以如下使用Bloc

```dart
void main() {
    CounterBloc bloc = CounterBloc();

    for (int i = 0; i < 3; i++) {
        bloc.add(CounterEvent.increment);
    }
}
```

默认情况下，将始终按照事件添加的顺序处理事件，并将所有新添加的事件排队。 一旦mapEventToState完成执行，事件将被视为处理完成。

上面App的Transitions转变过程如下

```json
{
    "currentState": 0,
    "event": "CounterEvent.increment",
    "nextState": 1
}
{
    "currentState": 1,
    "event": "CounterEvent.increment",
    "nextState": 2
}
{
    "currentState": 2,
    "event": "CounterEvent.increment",
    "nextState": 3
}
```

## Flutter Bloc

### Bloc Widgets

#### BlocBuilder

BlocBuilder的功能与构建异步UI的StreamBuilder差不多，都是Widget组件，但API接口相对更简单。BlocBuilder要求传入Bloc和builder函数作为入参。builder函数返回所需要的UI Widget，由于Bloc中Event的变化所以builder可能会被多次触发。

如果传入参数中没有bloc参数，BlocBuilder会自动使用BlocProvider和当前的BuildContext来查找Bloc

```dart
BlocBuilder<BlocA, BlocAState>(
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

```dart
BlocBuilder<BlocA, BlocAState>(
  bloc: blocA, // provide the local bloc instance
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```

如果你需要控制何时调用builder构建函数，BlocBuilder提供了一个可选的condition参数，如果这个函数返回true那么builder函数则会重新调用重建，如果返回false则不会调用build不会被调用

```dart
BlocBuilder<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to rebuild the widget with state
  },
  builder: (context, state) {
    // return widget here based on BlocA's state
  }
)
```



#### BlocProvider

BlocProvider是通过BlocProvider.of<T>(context)能够为自己子控件提供bloc的Flutter Widget部件，他能将单个bloc实例提供个多个子树部件的依赖注入Widget部件。

在大多数情况下，BlocProvider是用来创建新的bloc。这个bloc可以供其子控件使用。BlocProvider负责自己创建和回收bloc。

```dart
BlocProvider(
  create: (BuildContext context) => BlocA(),
  child: ChildA(),
);
```

在某些情况下，BlocProvider也可以为小部件树新的部分提供已存在的bloc。这种情况下BlocProvider不会自动回收bloc，以为他没有创建bloc

```dart
BlocProvider.value(
  value: BlocProvider.of<BlocA>(context),
  child: ScreenA(),
);
```

按照上面的代码，我们可以在ChildA和ScreenA中检索出BlocA，通过以下的代码可以检索出来

```dart
BlocProvider.of<BlocA>(context)
```

#### MultiBlocProvider

MultiBlocProvider是一个能够将多个BlocProvider合并成一个的Flutter Widget部件。

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<BlocA>(
      create: (BuildContext context) => BlocA(),
    ),
    BlocProvider<BlocB>(
      create: (BuildContext context) => BlocB(),
    ),
    BlocProvider<BlocC>(
      create: (BuildContext context) => BlocC(),
    ),
  ],
  child: ChildA(),
)
```

#### BlocListener

BlocListener也是一个Flutter widget,它有两个入参，一个是可选的Bloc，和一个必传的listener函数。BlocListener用于用于每个状态更改需要发生一次的功能。比如说显示一个SnackBar、显示一个Dialog等等。

每个状态变化都只会调用一次listener函数(不包括initialState)，这一点和BlocBuilder中的builder函数不同。

当没传入bloc时，BlocListener会自动搜索当前上下文以查找bloc

```dart
BlocListener<BlocA, BlocAState>(
  listener: (context, state) {
    // do stuff here based on BlocA's state
  },
  child: Container(),
)
```

```dart
BlocListener<BlocA, BlocAState>(
  bloc: blocA,
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
)
```

如果想更好的控制listener函数被何时调用，BlocListenser也提供了以个condition入参来控制。这一点和BlocBuilder差不多

```dart
BlocListener<BlocA, BlocAState>(
  condition: (previousState, state) {
    // return true/false to determine whether or not
    // to call listener with state
  },
  listener: (context, state) {
    // do stuff here based on BlocA's state
  }
  child: Container(),
)
```



#### MultiBlocListener

MultiBlocListener是一个将多个BlocListenser合并在一起的Flutter Widget。

```dart
MultiBlocListener(
  listeners: [
    BlocListener<BlocA, BlocAState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocB, BlocBState>(
      listener: (context, state) {},
    ),
    BlocListener<BlocC, BlocCState>(
      listener: (context, state) {},
    ),
  ],
  child: ChildA(),
)
```

根据上面的知识我们可以使用Bloc写出如下的计数器App

```dart
enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}
```

```dart
class CounterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: BlocBuilder<CounterBloc, int>(
        builder: (context, count) {
          return Center(
            child: Text(
              '$count',
              style: TextStyle(fontSize: 24.0),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                counterBloc.add(CounterEvent.increment);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: FloatingActionButton(
              child: Icon(Icons.remove),
              onPressed: () {
                counterBloc.add(CounterEvent.decrement);
              },
            ),
          ),
        ],
      ),
    );
  }
}
```









