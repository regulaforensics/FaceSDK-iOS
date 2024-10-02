//
//  URLRequestInterceptorItem.swift
//  BasicSample
//
//  Created by Pavel Kondrashkov on 5/25/21.
//  Copyright © 2021 Regula. All rights reserved.
//

import FaceSDK

final class URLRequestInterceptorItem: CatalogItem {
    override init() {
        super.init()

        title = "Network interceptor"
        itemDescription = "Adds custom http fields to the outgoing requests"
        category = .other
    }

    override func onItemSelected(from viewController: UIViewController) {
        let service = FaceSDK.service
        service.requestInterceptingDelegate = self
        service.startLiveness(
            from: viewController,
            animated: true,
            onLiveness: { [weak self, weak service, weak viewController] response in
                guard let self = self, let viewController = viewController else { return }
                self.showLivenessResult(response, from: viewController)
                service?.requestInterceptingDelegate = nil
            },
            completion: nil
        )
    }
}

extension URLRequestInterceptorItem: URLRequestInterceptingDelegate {
    func interceptorPrepare(_ request: URLRequest) -> URLRequest? {
        var request = request
        request.addValue("MyCustomTokenValue", forHTTPHeaderField: "MyField")
        return request
    }
}
