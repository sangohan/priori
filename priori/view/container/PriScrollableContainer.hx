package priori.view.container;

import priori.system.PriDeviceBrowser;
import priori.event.PriMouseEvent;
import priori.system.PriDevice;
import priori.event.PriEvent;

class PriScrollableContainer extends PriGroup {

    @:isVar public var scroller(default, set):Bool;
    @:isVar public var scrollerX(default, set):Bool;
    @:isVar public var scrollerY(default, set):Bool;

    public var scrollY(get, set):Float;
    public var scrollX(get, set):Float;

    public var maxScrollY(get, null):Float;
    public var maxScrollX(get, null):Float;

    private var __mouseIsOver:Bool = false;

    public function new() {
        super();

        if (PriDevice.isMobileDevice()) {
            this.__mouseIsOver = true;
            this.scrollerY = true;
        } else {
            this.__mouseIsOver = false;
            this.scrollerY = true;

            this.addEventListener(PriMouseEvent.MOUSE_OVER, onOver);
            this.addEventListener(PriMouseEvent.MOUSE_OUT, onOut);
        }


    }

    private function onOver(e:PriMouseEvent):Void {
        this.__mouseIsOver = true;
        this.updateScrollerView();
    }

    private function onOut(e:PriMouseEvent):Void {
        this.__mouseIsOver = false;
        this.updateScrollerView();
    }

    private function updateScrollerView():Void {

        var canUpdate:Bool = true;

        if (PriDevice.browser() == PriDeviceBrowser.MOZILLA) {
            /* TODO
            / esta é uma solucao temporaria para um problema que faz com que
            / a caixa de selecao de um Select seja fechada quando modificar o overflow
            / por que a lista de itens causa um mouseleave no objeto pai
            */
            if (this.getElement().find("select:focus").length > 0) canUpdate = false;
        }

        if (canUpdate) {
            if (this.__mouseIsOver) {
                if (this.scrollerX && this.scrollerY) {
                    this.getElement().css("overflow", "auto");
                } else if (this.scrollerX) {
                    this.getElement().css("overflow-x", "auto");
                } else if (this.scrollerY) {
                    this.getElement().css("overflow-y", "auto");
                } else {
                    this.getElement().css("overflow", "hidden");
                }
            } else {
                this.getElement().css("overflow", "hidden");
            }
        }
    }


    override private function get_clipping():Bool return true;
    override private function set_clipping(value:Bool) return value;


    private function set_scrollerX(value:Bool) {
        this.scrollerX = value;
        if (this.__mouseIsOver) this.updateScrollerView();
        return value;
    }

    private function set_scrollerY(value:Bool) {
        this.scrollerY = value;
        if (this.__mouseIsOver) this.updateScrollerView();
        return value;
    }

    private function set_scroller(value:Bool) {
        this.scrollerX = value;
        this.scrollerY = value;
        return value;
    }


    private function get_scrollY():Float return this.getElement().scrollTop();
    private function set_scrollY(value:Float) {
        this.getElement().scrollTop(value);
        return value;
    }

    private function get_scrollX():Float return this.getElement().scrollLeft();
    private function set_scrollX(value:Float) {
        this.getElement().scrollLeft(value);
        return value;
    }

    private function get_maxScrollY():Float {
        var result:Float = Std.parseFloat(this.getElement().prop("scrollHeight"));
        if (result == null || Math.isNaN(result)) result = 0;

        return result;
    }

    private function get_maxScrollX():Float {
        var result:Float = Std.parseFloat(this.getElement().prop("scrollWidth"));
        if (result == null || Math.isNaN(result)) result = 0;

        return result;
    }

}
