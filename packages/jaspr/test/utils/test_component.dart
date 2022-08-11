import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

extension PumpTestComponent on ComponentTester {
  Future<TestComponentController<T>> pumpTestComponent<T>(TestComponent<T> component) async {
    await pumpComponent(component);
    Element? testElem;
    binding.rootElement!.visitChildren((element) {
      element.visitChildren((element) {
        testElem ??= element;
      });
    });
    return TestComponentController(testElem!);
  }
}

class TestComponentController<T> {
  TestComponentController(this._element);

  final Element _element;
  StatefulElement get element => _element as StatefulElement;

  _TestState get state => element.state as _TestState;

  Future<void> rebuild() {
    _element.markNeedsBuild();
    return pumpEventQueue();
  }

  Future<void> rebuildWith(T value) {
    state.value = value;
    return rebuild();
  }
}

abstract class TestComponent<T> extends StatefulComponent {
  TestComponent({required this.initialValue});

  final T initialValue;

  @protected
  Iterable<Component> build(BuildContext context, T value);

  @override
  State<StatefulComponent> createState() => _TestState();
}

class _TestState<T> extends State<TestComponent> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = component.initialValue;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield* component.build(context, value);
  }
}
