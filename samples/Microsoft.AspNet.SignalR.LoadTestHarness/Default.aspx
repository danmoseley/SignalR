﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Microsoft.AspNet.SignalR.LoadTestHarness.Default" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=Edge" />
    <title>SignalR Flywheel</title>
    <style>
        body { font-family: 'Segoe UI'; padding: 0 20px; margin: 0; }
        h1, h2, h3, h4, h5 { font-family: 'Segoe UI'; font-weight: normal; margin: 0 0 5px; }
        table { border-collapse: collapse; background-color: #fff }
            table tbody tr { background-color: #fdff6d }
            table td { border: 1px solid #808080; }
        select, input[type=text] { margin: 2px 0 }
        #options { margin-bottom: 5px; width: 400px; padding: 6px 12px; float: left; }
        #options label { display: block; float: left; width: 150px;  }
        #chart {
            float: left;
            clear: right;
            margin-top: -45px;
            width: 700px;
            height: 200px;
        }
        #rate { width: 50px; }
        #stats div { clear: both; font-size: 18px; margin-left: 50px; }
        #stats strong { display: block; float: left; width: 250px; }
        #stats span { display: block; float: left; width: 150px; text-align: right; }
    </style>
</head>
<body>
    <h1>SignalR Flywheel</h1>
    
    <fieldset id="options"><legend>Endpoint Options</legend>
        <div>
            <label for="onReceive">On receive:</label>
            <select id="onReceive">
                <option value="0">Listen only</option>
                <option value="1">Echo</option>
                <option value="2">Broadcast</option>
            </select>
        </div>

        <div>
            <label for="rate">Broadcast rate:</label>
            <input id="rate" value="0" maxlength="5" /> (per second)
        </div>

        <div>
            <label for="payloadSize">Broadcast size:</label>
            <select id="payloadSize">
                <option value="32">32 bytes</option>
                <option value="64">64 bytes</option>
                <option value="128">128 bytes</option>
                <option value="256">256 bytes</option>
                <option value="1024">1024 bytes</option>
                <option value="4096">4096 bytes</option>
            </select>
        </div>

        <div>
            <a id="resetAvg" href="#">Reset average</a>
            <a id="forceGC" href="#">Force GC</a>
        </div>
    </fieldset>

    <script src="Scripts/jquery-1.7.2.js"></script>
    <script src="Scripts/jquery.signalR.js"></script>
    <script src="signalr/hubs"></script>
    <script>
        jQuery.fn.flash = function (color, duration) {
            var current = this.css("backgroundColor");
            this.animate({ backgroundColor: "rgb(" + color + ")" }, duration / 2)
                .animate({ backgroundColor: current }, duration / 2);
        };

        (function () {
            var hub = $.connection.flywheel,
                $onReceive = $("#onReceive"),
                $rate = $("#rate"),
                $payloadSize = $("#payloadSize");

            hub.client.onReceiveChanged = function (behavior) {
                $onReceive.val(behavior);
            };

            hub.client.onRateChanged = function (rate) {
                $rate.val(rate);
            };

            hub.client.onSizeChanged = function (size) {
                $payloadSize.val(size);
            };

            function init() {
                $onReceive.change(function () {
                    hub.server.setOnReceive($onReceive.val());
                });
                $rate.change(function () {
                    hub.server.setBroadcastRate($rate.val());
                });
                $payloadSize.change(function () {
                    hub.server.setBroadcastSize($payloadSize.val());
                });
                $("#resetAvg").click(function (e) {
                    e.preventDefault();
                    hub.server.resetAverage();
                });
                $("#forceGC").click(function (e) {
                    /// <param name="e" type="jQuery.Event">Description</param>
                    var link = $("#forceGC"),
                        text = link.text(),
                        href = link.prop("href");

                    e.preventDefault();

                    link.text("Collecting...")
                        .prop("href", "");

                    hub.server.forceGC().done(function () {
                        link.text(text)
                            .prop("href", href);
                    });
                });
            }

            $.connection.hub.start(init);
        })();
    </script>
</body>
</html>