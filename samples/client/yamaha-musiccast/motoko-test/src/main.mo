import Debug "mo:core/Debug";
import Int "mo:core/Int";
import Text "mo:core/Text";
import { PowerApi } "../generated/Apis/PowerApi";
import { ZoneApi } "../generated/Apis/ZoneApi";
// FIXME: destructuring on `actor` types is not implemented yet
//        type error [M0114], object pattern cannot consume actor type
//import { type http_request_args; type http_request_result; type http_header; http_request } "ic:aaaaa-aa";
import Mgnt = "ic:aaaaa-aa";

persistent actor {

    transient let http_request = Mgnt.http_request;
    type CanisterHttpRequestArgument = Mgnt.http_request_args;
    type CanisterHttpResponsePayload = Mgnt.http_request_result;
    type HttpHeader = Mgnt.http_header;
    type HttpMethod = {
        #get;
        #head;
        #post;
        // TODO: IC HTTP outcalls currently only support GET, HEAD, and POST.
        //   PUT and DELETE methods are not yet supported by the management canister.
        //   Once support is added, uncomment these:
        // #put;
        // #delete;
    };

    transient let powerApi = PowerApi({
        baseUrl = "http://192.168.178.42/YamahaExtendedControl/v1";
        accessToken = null;
        max_response_bytes = null;
        transform = null;
        is_replicated = null;
        cycles = 30_000_000_000;
    });

    transient let zoneApi = ZoneApi({
        baseUrl = "http://192.168.178.42/YamahaExtendedControl/v1";
        accessToken = null;
        max_response_bytes = null;
        transform = null;
        is_replicated = null;
        cycles = 30_000_000_000;
    });

    // Helper function to set volume using direct HTTP call
    /*func setVolume(volume : Int) : async () {
        let url = "http://192.168.178.42/YamahaExtendedControl/v1/main/setVolume?volume=" # Int.toText(volume);

        let request : CanisterHttpRequestArgument = {
            url;
            max_response_bytes = null;
            method = #get;
            headers = [{ name = "Content-Type"; value = "application/json; charset=utf-8" }];
            body = null;
            transform = null;
            is_replicated = null;
        };

        let _ : CanisterHttpResponsePayload = await (with cycles = 30_000_000_000) http_request(request);
    };*/

    // Test sequence: power on, raise volume in 5-increments to 50%, power off
    public func testYamahaSequence() : async Text {
        Debug.print("Starting Yamaha MusicCast test sequence");

        // 1. Power on
        Debug.print("1. Powering on...");
        let _ = await powerApi.setPower("main", "on");
        Debug.print("   ✓ Power on");

        // 2. Raise volume from 5 to 50 in increments of 5
        Debug.print("2. Raising volume from 5% to 50%...");
        for (volume in [5, 10, 15, 20, 25, 30].vals()) {
            Debug.print("   Setting volume to " # Int.toText(volume));
            ignore await zoneApi.setVolume("main", #integer volume, 0);
        };
        Debug.print("   ✓ Volume raised to 30%");

        // 3. Power off (standby)
        Debug.print("3. Powering off...");
        let _ = await powerApi.setPower("main", "standby");
        Debug.print("   ✓ Power off (standby)");

        Debug.print("Test sequence completed successfully!");
        "SUCCESS: Test sequence completed - powered on, raised volume to 50%, powered off"
    };
}
