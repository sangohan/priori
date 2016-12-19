package helper.browser;

import priori.event.PriFocusEvent;
import priori.event.PriKeyboardEvent;
import priori.event.PriTapEvent;
import priori.event.PriEvent;
import priori.view.PriDisplay;
import priori.event.PriMouseEvent;
import js.html.Element;
import js.Browser;
import jQuery.JQuery;

class BrowserEventEngine {

    private static var SPECIAL_EVENT_LIST:Array<String> = [
        "mouseleave",
        "mouseenter",
        "mousedown",
        "mouseup",
        "click",

        "keyup",
        "keydown",

        "focusin",
        "focusout"
    ];

    public var registeredEvent:Array<String> = [];

    public var jqel:JQuery;
    public var jsel:Element;
    public var display:PriDisplay;

    public function new() {

    }

    public function onAddedToApp(e:PriEvent):Void {
        this.addAllActions();
        this.display.addEventListener(PriEvent.REMOVED_FROM_APP, this.onRemovedFromApp);
        this.display.removeEventListener(PriEvent.ADDED_TO_APP, this.onAddedToApp);
    }

    public function onRemovedFromApp(e:PriEvent):Void {
        this.removeAllActions();
        this.display.removeEventListener(PriEvent.REMOVED_FROM_APP, this.onRemovedFromApp);
        this.display.addEventListener(PriEvent.ADDED_TO_APP, this.onAddedToApp);
    }

    public function registerEvent(event:String):Void {
        if (!this.isSpecial(event)) return;

        if (registeredEvent.indexOf(event) == -1) {
            this.registeredEvent.push(event);
            if (this.isOnDom()) {
                this.attachToElement(event);
            }
        }
    }

    public function removeAllActions():Void {
        for (i in 0 ... registeredEvent.length) {
            this.dettachFromElement(registeredEvent[i]);
        }
    }

    public function addAllActions():Void {
        for (i in 0 ... registeredEvent.length) {
            this.attachToElement(registeredEvent[i]);
        }
    }

    inline public function isOnDom():Bool {
        return Browser.document.documentElement.contains(this.jsel);
    }

    inline public function isSpecial(event:String):Bool {
        return SPECIAL_EVENT_LIST.indexOf(event) > -1;
    }

    public function attachToElement(event:String):Void {
        switch event {
            case "mouseleave" : this.jqel.on("mouseleave", this.on_mouse_leave);
            case "mouseenter" : this.jqel.on("mouseenter", this.on_mouse_enter);
            case "mousedown" : this.jqel.on("mousedown", this.on_mouse_down);
            case "mouseup" : this.jqel.on("mouseup", this.on_mouse_up);
            case "click" : this.jqel.on("click", this.on_mouse_click);

            case "keyup" : this.jqel.on("keyup", this.on_keyboard_up);
            case "keydown" : this.jqel.on("keydown", this.on_keyboard_down);
            case "focusin" : this.jqel.on("focusin", this.on_focus_in);
            case "focusout" : this.jqel.on("focusout", this.on_focus_out);
        }
    }

    public function dettachFromElement(event:String):Void {
        switch event {
            case "mouseleave" : this.jqel.off("mouseleave", this.on_mouse_leave);
            case "mouseenter" : this.jqel.off("mouseenter", this.on_mouse_enter);
            case "mousedown" : this.jqel.off("mousedown", this.on_mouse_down);
            case "mouseup" : this.jqel.off("mouseup", this.on_mouse_up);
            case "click" : this.jqel.off("click", this.on_mouse_click);

            case "keyup" : this.jqel.off("keyup", this.on_keyboard_up);
            case "keydown" : this.jqel.off("keydown", this.on_keyboard_down);
            case "focusin" : this.jqel.off("focusin", this.on_focus_in);
            case "focusout" : this.jqel.off("focusout", this.on_focus_out);
        }
    }

    private function on_focus_in(e:Dynamic):Void {
        if (!this.display.visible || this.display.disabled) return;
        var pe:PriFocusEvent = new PriFocusEvent(PriFocusEvent.FOCUS_IN);
        this.display.dispatchEvent(pe);
    }

    private function on_focus_out(e:Dynamic):Void {
        if (!this.display.visible || this.display.disabled) return;
        var pe:PriFocusEvent = new PriFocusEvent(PriFocusEvent.FOCUS_OUT);
        this.display.dispatchEvent(pe);
    }


    private function on_keyboard_up(e:Dynamic):Void {
        if (this.display.disabled) return;
        var pe:PriKeyboardEvent = new PriKeyboardEvent(PriKeyboardEvent.KEY_UP);
        pe.keycode = e.which;
        pe.altKey = e.altKey;
        pe.ctrlKey = e.ctrlKey || e.metaKey;
        pe.shiftKey = e.shiftKey;
        this.display.dispatchEvent(pe);
    }
    private function on_keyboard_down(e:Dynamic):Void {
        if (this.display.disabled) return;
        var pe:PriKeyboardEvent = new PriKeyboardEvent(PriKeyboardEvent.KEY_DOWN);
        pe.keycode = e.which;
        pe.altKey = e.altKey;
        pe.ctrlKey = e.ctrlKey || e.metaKey;
        pe.shiftKey = e.shiftKey;
        this.display.dispatchEvent(pe);
    }

    private function on_mouse_down(e:Dynamic):Void {
        if (this.display.disabled) return;
        var pe:PriTapEvent = new PriTapEvent(PriTapEvent.TAP_DOWN);
        this.display.dispatchEvent(pe);
    }

    private function on_mouse_up(e:Dynamic):Void {
        if (this.display.disabled) return;
        var pe:PriTapEvent = new PriTapEvent(PriTapEvent.TAP_UP);
        this.display.dispatchEvent(pe);
    }

    private function on_mouse_click(e:Dynamic):Void {
        if (this.display.disabled) return;
        var pe:PriTapEvent = new PriTapEvent(PriTapEvent.TAP);
        this.display.dispatchEvent(pe);
    }
    private function on_mouse_enter(e:Dynamic):Void {
        if (this.display.disabled) return;
        var pe:PriMouseEvent = new PriMouseEvent(PriMouseEvent.MOUSE_OVER);
        this.display.dispatchEvent(pe);
    }

    private function on_mouse_leave(e:Dynamic):Void {
        if (this.display.disabled) return;
        var pe:PriMouseEvent = new PriMouseEvent(PriMouseEvent.MOUSE_OUT);
        this.display.dispatchEvent(pe);
    }

    public function kill():Void {
        this.removeAllActions();
        this.registeredEvent = [];
        this.display.removeEventListener(PriEvent.REMOVED_FROM_APP, this.onRemovedFromApp);
        this.display.removeEventListener(PriEvent.ADDED_TO_APP, this.onAddedToApp);
    }
}