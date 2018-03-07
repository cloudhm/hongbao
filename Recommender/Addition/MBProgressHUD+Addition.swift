//
//  MBProgressHUD+Addition.swift
//  Foo
//
//  Created by huangmin on 30/11/2017.
//  Copyright © 2017 YedaoDev. All rights reserved.
//

import Foundation
import MBProgressHUD
extension MBProgressHUD {
    /**
     * show animated images hud
     */
    static func showAnimationView(_ inView : UIView?) {
        guard let view = inView  else { return }
        MBProgressHUD.hide(for: view, animated: true)
        let hud = MBProgressHUD.showAdded(to: view, animated: false)
        hud.mode = .indeterminate
        hud.bezelView.style = .solidColor
        hud.backgroundView.style = .solidColor
        hud.show(animated: true)
    }
    /**
     * hide all huds
     */
    static func hide(_ inView : UIView?) {
        guard let view = inView  else { return }
        let notLast = MBProgressHUD.hide(for: view, animated: true)
        if notLast {
            // notLast is true, then show there is some huds in current view
            // recursion logic
            hide(view)
        }
    }
}

