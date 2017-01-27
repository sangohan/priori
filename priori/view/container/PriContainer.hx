package priori.view.container;

import js.Browser;
import js.html.DocumentFragment;
import helper.browser.DomHelper;
import priori.geom.PriGeomBox;
import priori.event.PriEvent;

class PriContainer extends PriDisplay {

    @:allow(priori.event.PriEventDispatcher)
    private var _childList:Array<PriDisplay> = [];
    private var _migratingView:Bool = false;

    public var numChildren(get, null):Int;

    public function new() {
        super();
    }

    private function get_numChildren():Int return this._childList.length;

    public function getChild(index:Int):PriDisplay {
        var result:PriDisplay = null;

        if (index < this._childList.length) {
            result = this._childList[index];
        }

        return result;
    }

    public function addChildList(childList:Array<Dynamic>):Void {
        var realItens:Array<Dynamic> = [];
        for (i in 0 ... childList.length) if (Std.instance(childList[i], PriDisplay) != null) realItens.push(childList[i]);

        var thisHasApp:Bool = this.hasApp();
        var thisDisabled:Bool = this.disabled;
        var thisHasDisabledParent:Bool = this.hasDisabledParent();

        var docFrag:DocumentFragment = Browser.document.createDocumentFragment();

        for (i in 0 ... realItens.length) {
            var child:PriDisplay = realItens[i];

            child.removeFromParent();

            this._childList.push(child);
            child._parent = this;


            if (thisHasApp) {
                if (thisDisabled) DomHelper.disableAll(child.getJSElement());
                else if (!thisHasDisabledParent) DomHelper.enableAllUpPrioriDisabled(child.getJSElement());
            }

            docFrag.appendChild(child.getJSElement());
        }

        this._jselement.appendChild(docFrag);

        for (i in 0 ... realItens.length) {
            var child:PriDisplay = realItens[i];
            if (thisHasApp) child.dispatchEvent(new PriEvent(PriEvent.ADDED_TO_APP, true));
            child.dispatchEvent(new PriEvent(PriEvent.ADDED, true));
        }
    }

    public function removeChildList(childList:Array<Dynamic>):Void {
        var realItens:Array<Dynamic> = [];
        for (i in 0 ... childList.length) if (Std.instance(childList[i], PriDisplay) != null) realItens.push(childList[i]);

        var hasAppBefore:Bool = this.hasApp();

        for (i in 0 ... realItens.length) {
            var child:PriDisplay = realItens[i];

            if (child.parent == this) {
                this._childList.remove(child);
                this._jselement.removeChild(child.getJSElement());

                child._parent = null;

                if (hasAppBefore) child.dispatchEvent(new PriEvent(PriEvent.REMOVED_FROM_APP, true));
                child.dispatchEvent(new PriEvent(PriEvent.REMOVED, true));
            }
        }
    }

    public function addChild(child:PriDisplay):Void this.addChildList([child]);
    public function removeChild(child:PriDisplay):Void this.removeChildList([child]);

    override public function kill():Void {

        for (i in 0 ... this._childList.length) {
            this._childList[i].kill();
        }

        this._childList = [];

        super.kill();
    }

    public function getContentBox():PriGeomBox {
        var result:PriGeomBox = new PriGeomBox();

        var i:Int = 0;
        var n:Int = this.numChildren;

        while (i < n) {

            result.x = Math.min(result.x, this.getChild(i).x);
            result.y = Math.min(result.y, this.getChild(i).y);

            result.width = Math.max(result.width, this.getChild(i).maxX);
            result.height = Math.max(result.height, this.getChild(i).maxY);

            i++;
        }

        return result;
    }

    override private function set_width(value:Float):Float {
        if (value != this.width) {
            super.set_width(value);
            this.dispatchEvent(new PriEvent(PriEvent.RESIZE, false));
        }

        this.updateBorderDisplay();

        return value;
    }

    override private function set_height(value:Float):Float {
        if (value != this.height) {
            super.set_height(value);
            this.dispatchEvent(new PriEvent(PriEvent.RESIZE, false));
        }

        this.updateBorderDisplay();

        return value;
    }
}
