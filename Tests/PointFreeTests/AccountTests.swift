import Either
import Html
import HtmlPrettyPrint
import HttpPipeline
@testable import PointFree
import PointFreeTestSupport
import Prelude
import Optics
import SnapshotTesting
import XCTest
#if !os(Linux)
  import WebKit
#endif

func request(to urlString: String) -> URLRequest {
  let sessionCookie = """
  e78e522838eb96eb96253b60dca1f4afc46adfc6f2e8f6700f03b2b7df656c6d\
  bacd144a80672f96a0a077faf1b63f0de0ba20e2c6bfaaa321853ab5bfb20e8d\
  e3212f5827ef1f51d4542ee4e6920dbcc991459f02f1bdb778782d4a88a7abce
  """

  return URLRequest(url: URL(string: urlString)!)
    |> \.allHTTPHeaderFields .~ [
      "Cookie": "pf_session=\(sessionCookie)",
      "Authorization": "Basic " + Data("hello:world".utf8).base64EncodedString()
  ]
}

class AccountTests: TestCase {
  override func setUp() {
    super.setUp()
    AppEnvironment.push(\.database .~ .mock)
  }

  override func tearDown() {
    super.tearDown()
    AppEnvironment.pop()
  }
  
  func testAccount() {
    let subscription = Stripe.Subscription.mock
      |> \.quantity .~ 5
      |> \.plan.id .~ .teamYearly
      |> \.plan.interval .~ .year

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: url(to: .account)))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")

          webView.frame.size.width = 400
          assertSnapshot(matching: webView, named: "mobile")

        }
      #endif
    }
  }

  func testAccountCancelingSubscription() {
    let subscription = Stripe.Subscription.canceling

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: url(to: .account)))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")

          webView.frame.size.width = 400
          assertSnapshot(matching: webView, named: "mobile")

        }
      #endif
    }
  }

  func testAccountCanceledSubscription() {
    let subscription = Stripe.Subscription.canceled

    AppEnvironment.with(\.stripe.fetchSubscription .~ const(pure(subscription))) {
      let conn = connection(from: request(to: url(to: .account)))
      let result = conn |> siteMiddleware

      assertSnapshot(matching: result.perform())

      #if !os(Linux)
        if #available(OSX 10.13, *) {
          let webView = WKWebView(frame: .init(x: 0, y: 0, width: 1080, height: 2000))
          webView.loadHTMLString(String(data: result.perform().data, encoding: .utf8)!, baseURL: nil)
          assertSnapshot(matching: webView, named: "desktop")

          webView.frame.size.width = 400
          assertSnapshot(matching: webView, named: "mobile")

        }
      #endif
    }
  }
}
