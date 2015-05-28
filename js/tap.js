(function (window) {
    var utils = {};
    var Tap = {};

    utils.attachEvent = function (element, eventName, callback) {
        if ('addEventListener' in window) {
            return element.addEventListener(eventName, callback, false);
        }
    };

    utils.fireFakeEvent = function (e, eventName) {
        if (document.createEvent) {
            return e.target.dispatchEvent(utils.createEvent(eventName));
        }
    };

    utils.createEvent = function (name) {
        if (document.createEvent) {
            var event = window.document.createEvent('HTMLEvents');
            event.initEvent(name, true, true);
            event.eventName = name;
            return event;
        }
    };

    utils.getRealEvent = function (e) {
        if (e.originalEvent && e.originalEvent.touches && e.originalEvent.touches.length) {
            return e.originalEvent.touches[0];
        } else if (e.touches && e.touches.length) {
            return e.touches[0];
        }
        return e;
    };


    Tap.options = {
        eventName: 'tap',
        fingerMaxOffset: 11
    };

    var attachDeviceEvent, init, handlers, deviceEvents,
        coords = {};

    attachDeviceEvent = function (eventName) {
        return utils.attachEvent(document.documentElement, deviceEvents[eventName], handlers[eventName]);
    };

    handlers = {
        start: function (e) {
            e = utils.getRealEvent(e);

            coords.start = [e.pageX, e.pageY];
            coords.offset = [0, 0];
        },

        move: function (e) {
            if (!coords['start'] && !coords['move']) {
                return false;
            }

            e = utils.getRealEvent(e);

            coords.move = [e.pageX, e.pageY];
            coords.offset = [
                Math.abs(coords.move[0] - coords.start[0]),
                Math.abs(coords.move[1] - coords.start[1])
            ];
        },

        end: function (e) {
            e = utils.getRealEvent(e);

            if (coords.offset[0] < Tap.options.fingerMaxOffset && coords.offset[1] < Tap.options.fingerMaxOffset && !utils.fireFakeEvent(e, Tap.options.eventName)) {
                e.preventDefault();
            }

            coords = {};
        },

        click: function (e) {
            if (!utils.fireFakeEvent(e, Tap.options.eventName)) {
                return e.preventDefault();
            }
        }
    };

    init = function () {
        deviceEvents = {
            start: 'touchstart',
            move: 'touchmove',
            end: 'touchend'
        };
        attachDeviceEvent('start');
        attachDeviceEvent('move');
        attachDeviceEvent('end');

        return utils.attachEvent(document.documentElement, 'click', handlers['click']);
    };

    utils.attachEvent(window, 'load', init);

    window.Tap = Tap;
})(window);