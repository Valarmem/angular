@Tags(const ['codegen'])
@TestOn('browser')
library angular2.test.compiler.xhr_mock_test;

import 'dart:async';

import 'package:test/test.dart';
import 'package:angular/src/compiler/xhr_mock.dart' show MockXHR;

import '../test_util.dart';

void main() {
  group('MockXHR', () {
    MockXHR xhr;
    setUp(() {
      xhr = new MockXHR();
    });
    expectResponse(Future<String> request, String url, String response) {
      String onResponse(String text) {
        if (identical(response, null)) {
          throw 'Unexpected response $url -> $text';
        } else {
          expect(text, response);
        }
        return text;
      }

      String onError(String error) {
        if (!identical(response, null)) {
          throw 'Unexpected error $url';
        } else {
          expect(error, 'Failed to load $url');
        }
        return error;
      }

      request.then(onResponse, onError: onError);
    }

    test('should return a response from the definitions', () async {
      var url = '/foo';
      var response = 'bar';
      xhr.when(url, response);
      expectResponse(xhr.get(url), url, response);
      xhr.flush();
    });
    test('should return an error from the definitions', () async {
      var url = '/foo';
      xhr.when(url, null);
      expectResponse(xhr.get(url), url, null);
      xhr.flush();
    });
    test('should return a response from the expectations', () async {
      var url = '/foo';
      var response = 'bar';
      xhr.expect(url, response);
      expectResponse(xhr.get(url), url, response);
      xhr.flush();
    });
    test('should return an error from the expectations', () async {
      var url = '/foo';
      xhr.expect(url, null);
      expectResponse(xhr.get(url), url, null);
      xhr.flush();
    });
    test('should not reuse expectations', () {
      var url = '/foo';
      var response = 'bar';
      xhr.expect(url, response);
      xhr.get(url);
      xhr.get(url);
      expect(() {
        xhr.flush();
      }, throwsWith('Unexpected request /foo'));
    });
    test('should return expectations before definitions', () async {
      var url = '/foo';
      xhr.when(url, 'when');
      xhr.expect(url, 'expect');
      expectResponse(xhr.get(url), url, 'expect');
      expectResponse(xhr.get(url), url, 'when');
      xhr.flush();
    });
    test('should throw when there is no definitions or expectations', () {
      xhr.get('/foo');
      expect(() {
        xhr.flush();
      }, throwsWith('Unexpected request /foo'));
    });
    test('should throw when flush is called without any pending requests', () {
      expect(() {
        xhr.flush();
      }, throwsWith('No pending requests to flush'));
    });
    test('should throw on unsatisfied expectations', () {
      xhr.expect('/foo', 'bar');
      xhr.when('/bar', 'foo');
      xhr.get('/bar');
      expect(() {
        xhr.flush();
      }, throwsWith('Unsatisfied requests: /foo'));
    });
  });
}
