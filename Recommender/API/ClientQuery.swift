//
//  ClientQuery.swift
//  Storefront
//
//  Created by Shopify.
//  Copyright (c) 2017 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import MobileBuySDK

final class ClientQuery {
    // ----------------------------------
    //  MARK: - Customer -
    //
}
/**
 * RootQuery
 */
extension ClientQuery {
    static func queryProductList(_ cursor : String?)->Storefront.QueryRootQuery {
        return Storefront.buildQuery{ $0
            .shop{ $0
                .products(first:250, after : cursor, reverse:true){ $0
                    .edges{$0
                        .cursor()
                        .node{$0
                            .id()
                            .title()
                            .images(first:1){$0
                                .edges{$0
                                    .node{$0
                                        .src()
                                    }
                                }
                            }
                            .options(first:3){$0
                                .name()
                                .values()
                            }
                            .handle()
                            .variants(first:1){$0
                                .edges{$0
                                    .node{$0
                                        .price()
                                        .compareAtPrice()
                                    }
                                }
                            }
                        }
                    }
                    .pageInfo{$0
                        .hasNextPage()
                    }
                }
            }
        }
    }
}

