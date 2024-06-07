@testable import DivKit

import XCTest

final class DivActionHandlerTests: XCTestCase {
  private var actionHandler: DivActionHandler!
  private let logger = MockActionLogger()
  private let reporter = MockReporter()
  private let variablesStorage = DivVariablesStorage()

  private var handledUrl: URL?

  override func setUp() {
    actionHandler = DivActionHandler(
      stateUpdater: DefaultDivStateManagement(),
      patchProvider: MockPatchProvider(),
      variablesStorage: variablesStorage,
      updateCard: { _ in },
      logger: logger,
      urlHandler: DivUrlHandlerDelegate { url, _ in self.handledUrl = url },
      reporter: reporter
    )
  }

  func test_UrlPassedToUrlHandler() {
    handle(
      divAction(
        logId: "test_log_id",
        url: "https://some.url"
      )
    )

    XCTAssertEqual(url("https://some.url"), handledUrl)
  }

  func test_UrlNotPassedToUrlHandler_IfTypedActionHandled() {
    handle(
      divAction(
        logId: "test_log_id",
        typed: .divActionSetVariable(
          DivActionSetVariable(
            value: stringValue("new value"),
            variableName: .value("string_var")
          )
        ),
        url: "https://some.url"
      )
    )

    XCTAssertNil(handledUrl)
  }

  func test_ArrayInsertValueAction_AppendsValue() {
    setVariableValue("array_var", .array([1, "two"]))

    handle(.divActionArrayInsertValue(
      DivActionArrayInsertValue(
        value: stringValue("new value"),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual([1, "two", "new value"] as [AnyHashable], getVariableValue("array_var"))
  }

  func test_ArrayInsertValueAction_InsertsValue() {
    setVariableValue("array_var", .array([1, "two"]))

    handle(.divActionArrayInsertValue(
      DivActionArrayInsertValue(
        index: .value(1),
        value: stringValue("new value"),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual([1, "new value", "two"] as [AnyHashable], getVariableValue("array_var"))
  }

  func test_ArrayInsertValueAction_WithIndexEqualLength_InsertsValue() {
    setVariableValue("array_var", .array(["one", "two"]))

    handle(.divActionArrayInsertValue(
      DivActionArrayInsertValue(
        index: .value(2),
        value: stringValue("new value"),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual(["one", "two", "new value"], getVariableValue("array_var"))
  }

  func test_ArrayInsertValueAction_DoesNothingForInvalidIndex() {
    setVariableValue("array_var", .array([1, "two"]))

    handle(.divActionArrayInsertValue(
      DivActionArrayInsertValue(
        index: .value(10),
        value: stringValue("new value"),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual([1, "two"] as [AnyHashable], getVariableValue("array_var"))
  }

  func test_ArrayInsertValueAction_DoesNothingForNotArrayVar() {
    setVariableValue("string_var", .string("value"))

    handle(.divActionArrayInsertValue(
      DivActionArrayInsertValue(
        value: stringValue("new value"),
        variableName: .value("string_var")
      )
    ))

    XCTAssertEqual("value", getVariableValue("string_var"))
  }

  func test_ArrayRemoveValueAction_RemovesValue() {
    setVariableValue("array_var", .array([1, "two"]))

    handle(.divActionArrayRemoveValue(
      DivActionArrayRemoveValue(
        index: .value(1),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual([1] as [AnyHashable], getVariableValue("array_var"))
  }

  func test_ArrayRemoveValueAction_DoesNothingForInvalidIndex() {
    setVariableValue("array_var", .array([1, "two"]))

    handle(.divActionArrayRemoveValue(
      DivActionArrayRemoveValue(
        index: .value(10),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual([1, "two"] as [AnyHashable], getVariableValue("array_var"))
  }

  func test_ArrayRemoveValueAction_DoesNothingForNotArrayVar() {
    setVariableValue("string_var", .string("value"))

    handle(.divActionArrayRemoveValue(
      DivActionArrayRemoveValue(
        index: .value(0),
        variableName: .value("string_var")
      )
    ))

    XCTAssertEqual("value", getVariableValue("string_var"))
  }

  func test_ArraySetValueAction_SetsValue() {
    setVariableValue("array_var", .array(["one", "two"]))

    handle(.divActionArraySetValue(
      DivActionArraySetValue(
        index: .value(1),
        value: stringValue("new value"),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual(["one", "new value"], getVariableValue("array_var"))
  }

  func test_ArraySetValueAction_DoesNothingForInvalidIndex() {
    setVariableValue("array_var", .array(["one", "two"]))

    handle(.divActionArraySetValue(
      DivActionArraySetValue(
        index: .value(2),
        value: stringValue("new value"),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual(["one", "two"], getVariableValue("array_var"))
  }

  func test_ArraySetValueAction_DoesNothingForNotArrayVar() {
    setVariableValue("string_var", .string("value"))

    handle(.divActionArraySetValue(
      DivActionArraySetValue(
        index: .value(0),
        value: stringValue("new value"),
        variableName: .value("string_var")
      )
    ))

    XCTAssertEqual("value", getVariableValue("string_var"))
  }

  func test_DictSetValueAction_AddsValue() {
    setVariableValue("dict_var", .dict([:]))

    handle(.divActionDictSetValue(
      DivActionDictSetValue(
        key: .value("key"),
        value: stringValue("new value"),
        variableName: .value("dict_var")
      )
    ))

    XCTAssertEqual(["key": "new value"], getVariableValue("dict_var"))
  }

  func test_DictSetValueAction_UpdatesValue() {
    setVariableValue("dict_var", .dict(["key": "value"]))

    handle(.divActionDictSetValue(
      DivActionDictSetValue(
        key: .value("key"),
        value: .dictValue(DictValue(value: ["new_key": "new value"])),
        variableName: .value("dict_var")
      )
    ))

    XCTAssertEqual(["key": ["new_key": "new value"]], getVariableValue("dict_var"))
  }

  func test_DictSetValueAction_RemovesValue() {
    setVariableValue("dict_var", .dict(["key": "value"]))

    handle(.divActionDictSetValue(
      DivActionDictSetValue(
        key: .value("key"),
        variableName: .value("dict_var")
      )
    ))

    XCTAssertEqual(DivDictionary(), getVariableValue("dict_var"))
  }

  func test_DictSetValueAction_DoesNothingForNotDictVar() {
    setVariableValue("array_var", .array(["one", "two"]))

    handle(.divActionDictSetValue(
      DivActionDictSetValue(
        key: .value("key"),
        value: stringValue("new value"),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual(["one", "two"], getVariableValue("array_var"))
  }

  func test_SetVariableAction_SetsStringVariable() {
    setVariableValue("string_var", .string("default"))

    handle(.divActionSetVariable(
      DivActionSetVariable(
        value: stringValue("new value"),
        variableName: .value("string_var")
      )
    ))

    XCTAssertEqual("new value", getVariableValue("string_var"))
  }

  func test_SetVariableAction_SetsArrayVariable() {
    setVariableValue("array_var", .array([]))

    handle(.divActionSetVariable(
      DivActionSetVariable(
        value: .arrayValue(ArrayValue(value: .value(["value 1", "value 2"]))),
        variableName: .value("array_var")
      )
    ))

    XCTAssertEqual(["value 1", "value 2"], getVariableValue("array_var"))
  }

  func test_LoggerIsCalled() {
    handle(
      DivAction(
        logId: .value("test_log_id"),
        logUrl: .value(url("https://some.log.url")),
        payload: ["key": "value"],
        referer: .value(url("https://some.referer.url")),
        url: .value(url("https://some.url"))
      )
    )

    XCTAssertEqual(url("https://some.log.url"), logger.lastUrl)
    XCTAssertEqual(url("https://some.referer.url"), logger.lastReferer)
    XCTAssertEqual(["key": "value"], logger.lastPayload as! [String: AnyHashable])
  }

  func test_ActionIsReported() {
    handle(
      DivAction(
        logId: .value("test_log_id"),
        logUrl: .value(url("https://some.log.url")),
        payload: ["key": "value"],
        referer: .value(url("https://some.referer.url")),
        url: .value(url("https://some.url"))
      )
    )

    XCTAssertEqual(cardId, reporter.lastCardId)
    XCTAssertEqual("test_log_id", reporter.lastActionInfo?.logId)
    XCTAssertEqual(url("https://some.log.url"), reporter.lastActionInfo?.logUrl)
    XCTAssertEqual(url("https://some.referer.url"), reporter.lastActionInfo?.referer)
    XCTAssertEqual(["key": "value"], reporter.lastActionInfo?.payload as! [String: AnyHashable])
  }

  private func handle(_ action: DivActionBase) {
    actionHandler.handle(
      action,
      cardId: cardId,
      source: .tap,
      sender: nil
    )
  }

  private func handle(_ action: DivActionTyped) {
    actionHandler.handle(
      divAction(logId: "log_id", typed: action),
      cardId: cardId,
      source: .tap,
      sender: nil
    )
  }

  private func getVariableValue<T>(_ name: DivVariableName) -> T? {
    variablesStorage.makeVariables(for: cardId)[name]?.typedValue()
  }

  private func setVariableValue(_ name: DivVariableName, _ value: DivVariableValue) {
    variablesStorage.set(cardId: cardId, variables: [name: value])
  }
}

private func stringValue(_ value: String) -> DivTypedValue {
  .stringValue(StringValue(value: .value(value)))
}

private let cardId: DivCardID = "test_card"

private final class MockActionLogger: DivActionLogger {
  private(set) var lastUrl: URL?
  private(set) var lastReferer: URL?
  private(set) var lastPayload: [String: Any]?

  func log(url: URL, referer: URL?, payload: [String: Any]?) {
    lastUrl = url
    lastReferer = referer
    lastPayload = payload
  }
}

final class MockPatchProvider: DivPatchProvider {
  func getPatch(url _: URL, completion _: @escaping DivPatchProviderCompletion) {}

  func cancelRequests() {}
}

private final class MockReporter: DivReporter {
  private(set) var lastCardId: DivCardID?
  private(set) var lastActionInfo: DivActionInfo?
  private(set) var lastError: DivError?

  func reportAction(cardId: DivCardID, info: DivActionInfo) {
    lastCardId = cardId
    lastActionInfo = info
  }

  func reportError(cardId: DivCardID, error: DivError) {
    lastCardId = cardId
    lastError = error
  }
}
