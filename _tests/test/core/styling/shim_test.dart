@Tags(const ['codegen'])
@TestOn('browser')
library angular2.test.common.styling.shim_test;

import 'dart:html';

import 'package:angular_test/angular_test.dart';
import 'package:test/test.dart';
import 'package:angular/angular.dart';

void main() {
  group('host styling', () {
    tearDown(disposeAnyRunningTest);

    test('should apply host style', () async {
      var testBed = new NgTestBed<HostStyleTestComponent>();
      NgTestFixture<HostStyleTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.rootElement;
      expectColor(elm, '#40FF7F');
    });

    test('should apply host style to nested components', () async {
      var testBed = new NgTestBed<HostStyleContainerComponent>();
      NgTestFixture<HostStyleContainerComponent> testFixture =
          await testBed.create();
      Element host1 = testFixture.rootElement.querySelector('host-test');
      Element host2 = testFixture.rootElement.querySelector('host-test2');
      expectColor(host1, '#40FF7F');
      expectColor(host2, '#FF0000');
    });

    test('should apply style to element under host', () async {
      var testBed = new NgTestBed<HostElementSelectorTestComponent>();
      NgTestFixture<HostElementSelectorTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.rootElement.querySelector('div');
      expectColor(elm, '#FF0000');

      elm = testFixture.rootElement.querySelector('section');
      expectColor(elm, '#0000FF');
    });

    test('should apply style using element selector', () async {
      var testBed = new NgTestBed<ElementSelectorTestComponent>();
      NgTestFixture<ElementSelectorTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.rootElement.querySelector('div');
      expectColor(elm, '#A0B0C0');

      elm = testFixture.rootElement.querySelector('section');
      expectColor(elm, '#C0B0A0');
    });

    test("should apply style using element selector in nested components",
        () async {
      var testBed = new NgTestBed<ContentSelectorTestComponent>();
      NgTestFixture<ContentSelectorTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.rootElement.querySelector('#section1');
      expectColor(elm, '#008000');

      elm = testFixture.rootElement.querySelector('#section2');
      expectColor(elm, '#FF0000');

      elm = testFixture.rootElement.querySelector('#section3');
      expectColor(elm, '#008000');
    });

    test('element selector style should not leak into children', () async {
      var testBed = new NgTestBed<ContentSelectorTestComponent>();
      NgTestFixture<ContentSelectorTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.rootElement.querySelector('#sectionA');
      expectColor(elm, '#000000');
    });

    test('host selector should not override class binding on host', () async {
      var testBed = new NgTestBed<ClassOnHostTestComponent>();
      NgTestFixture<ClassOnHostTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.rootElement;
      expect(elm.className.startsWith('customhostclass _nghost-'), true);
    });

    test('should support [attr.class] bindings', () async {
      var testBed = new NgTestBed<ClassAttribBindingComponent>();
      NgTestFixture<ClassAttribBindingComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.rootElement.querySelector('#item1');
      expect(elm.className.startsWith('xyz _ngcontent-'), true);
    });

    test('should support class interpolation', () async {
      var testBed = new NgTestBed<ClassInterpolateComponent>();
      NgTestFixture<ClassInterpolateComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.rootElement.querySelector('#item1');
      expect(elm.className.startsWith('prefix xyz postfix _ngcontent-'), true);
    });

    test(
        'binding class on a component should add both content '
        'and host selector', () async {
      var testBed = new NgTestBed<ComponentContainerTestComponent>();
      NgTestFixture<ComponentContainerTestComponent> testFixture =
          await testBed.create();
      Element elm = testFixture.rootElement.querySelector('child-component1');
      expect(elm.className.contains('_ngcontent'), true);
      expect(elm.className.contains('_nghost'), true);
    });

    test('Should support native encapsulation', () async {
      var testBed = new NgTestBed<NativeContainerTest>();
      NgTestFixture<NativeContainerTest> testFixture = await testBed.create();
      Element elm = testFixture.rootElement;
      expect(elm.getComputedStyle().backgroundColor, 'rgb(255, 0, 0)');
    });
    test('Should apply shim class on top of host attr.class property',
        () async {
      var testBed = new NgTestBed<NgHostAttribShimTest>();
      var testFixture = await testBed.create();
      Element elm = testFixture.rootElement.querySelector('feature-promo');
      expect(elm.className.startsWith('position-class _nghost-'), true);
    });
  });
}

@Component(
    selector: 'host-test',
    template: '<div id="item1">Test1</div><ng-content></ng-content>',
    styles: const [':host { color: rgb(64, 255, 127); }'])
class HostStyleTestComponent {}

@Component(
    selector: 'host-test2',
    template: '<div id="item1">Test2</div>',
    styles: const [':host { color: red; }'])
class HostStyle2TestComponent {}

/// Nests one host inside other.
@Component(
    selector: 'host-container',
    template: '<host-test><host-test2></host-test2></host-test>',
    styles: const [':host { color: rgb(0, 0, 0); }'],
    directives: const [HostStyleTestComponent, HostStyle2TestComponent])
class HostStyleContainerComponent {}

@Component(
    selector: 'host-element-selector-test',
    template: '<div id="item1">Hello</div>'
        '<section class="disabled" id="item2">Hello</section>',
    styles: const [
      ':host > div { color: red; }'
          ':host section { color: blue; }'
    ])
class HostElementSelectorTestComponent {}

@Component(
    selector: 'element-selector-test',
    template: '<div id="item1">Hello</div>'
        '<section class="disabled" id="item2">Hello</section>',
    styles: const [
      'div { color: #A0B0C0; }'
          'section { color: #C0B0A0; }'
    ])
class ElementSelectorTestComponent {}

@Component(
    selector: 'content-selector-test',
    template: '<section class="sec1" id="section1">Section1</section>'
        '<section class="sec2 activated" id="section2">Section2</section>'
        '<section class="sec3" id="section3">Section3</section>'
        '<content-selector-test-child></content-selector-test-child>',
    styles: const [
      'section { color: green; }'
          'section.activated { color: red; }'
          'section.disabled { color: blue; }'
    ],
    directives: const [
      ContentSelectorChildComponent
    ])
class ContentSelectorTestComponent {}

@Component(
    selector: 'content-selector-test-child',
    template: '<section class="secA" id="sectionA">SectionA</section>'
        '<content-selector-test-child></content-selector-test-child>')
class ContentSelectorChildComponent {}

@Component(
  selector: 'class-on-host',
  template: '<div id="item1">Test1</div>',
  styles: const [':host { color: rgb(64, 255, 127); }'],
  host: const {'class': 'customhostclass'},
)
class ClassOnHostTestComponent {}

@Component(
  selector: 'class-attrib-binding',
  template: '<div id="item1" [attr.class]="someClass">Test1</div>',
  styles: const [':host { color: rgb(64, 255, 127); }'],
)
class ClassAttribBindingComponent {
  String get someClass => 'xyz';
}

@Component(
  selector: 'class-interpolate-test',
  template: '<div id="item1" class="prefix {{someClass}} postfix">Test1</div>',
  styles: const [':host { color: rgb(64, 255, 127); }'],
  host: const {'class': 'customhostclass'},
)
class ClassInterpolateComponent {
  String get someClass => 'xyz';
}

@Component(
    selector: 'component-container1',
    template: '<div><child-component1 class="{{activeClass}}">'
        '<div class="mobile"></div>'
        '</child-component1></div>',
    styles: const [':host { color: rgb(0, 0, 0); }'],
    directives: const [ChildComponent])
class ComponentContainerTestComponent {
  String get activeClass => 'active';
}

@Component(
  selector: 'child-component1',
  template: '<div id="child-div1"><ng-content></ng-content></div>',
  styles: const [':host { color: #FF0000; }'],
)
class ChildComponent {}

void expectColor(Element element, String color) {
  String elementColor = element.getComputedStyle().color;
  elementColor = colorToHex(elementColor);
  expect(elementColor, color);
}

void expectBackgroundColor(Element element, String color) {
  String elementColor = element.getComputedStyle().backgroundColor;
  elementColor = colorToHex(elementColor);
  expect(elementColor, color);
}

// Converts rgb() rgba() to hex color value.
String colorToHex(String value) {
  value = value.trim();
  if (value.startsWith('rgb')) {
    int parenStartIndex = value.indexOf('(');
    int parenEndIndex = value.lastIndexOf(')');
    if (parenStartIndex != -1 && parenEndIndex != -1) {
      List<String> components =
          value.substring(parenStartIndex + 1, parenEndIndex).split(',');
      StringBuffer sb = new StringBuffer();
      for (int i = 0, len = components.length; i < len && i < 3; i++) {
        String hex = int.parse(components[i]).toRadixString(16);
        if (hex.length < 2) sb.write('0');
        sb.write(hex);
      }
      if (components.length == 4) {
        // Parse alpha.
        String hex =
            (double.parse(components[3]) * 256).toInt().toRadixString(16);
        if (hex.length < 2) hex = '0$hex';
        return '#$hex$sb}';
      }
      return '#${sb.toString().toUpperCase()}';
    }
  }
  return value;
}

@Component(
    selector: 'native-host-test',
    template: '<div id="item1">Test1</div><native-comp></native-comp>'
        '<ng-content></ng-content>',
    styles: const [':host { background-color: red; }'],
    directives: const [NativeComp],
    encapsulation: ViewEncapsulation.Native)
class NativeContainerTest {}

@Component(
    selector: 'native-comp',
    template: '<div id="item1">Test1</div><ng-content></ng-content>',
    styles: const [':host { background-color: blue; }'],
    encapsulation: ViewEncapsulation.Native)
class NativeComp {}

@Component(
    selector: 'feature-promo',
    host: const {'[attr.class]': 'positionClass'},
    styles: const [':host {position: absolute;}'],
    template: '<div>Hello</div>')
class FeaturePromoComponent {
  @Input()
  String positionClass;
}

@Component(
    selector: 'feature-promo-test',
    directives: const [FeaturePromoComponent],
    template: '''<div>
      <feature-promo [positionClass]="myposition"></feature-promo>
    </div>''')
class NgHostAttribShimTest {
  String myposition;
  NgHostAttribShimTest() {
    myposition = "position-class";
  }
}
