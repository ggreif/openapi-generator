import Debug "mo:core/Debug";
import Int "mo:core/Int";
import { PowerApi } "../generated/Apis/PowerApi";
import { ZoneApi } "../generated/Apis/ZoneApi";
import { type SetPowerPowerParameter; JSON = SetPowerPowerParameter } "../generated/Models/SetPowerPowerParameter";
import { type SetVolumeVolumeParameter; JSON = SetVolumeVolumeParameter } "../generated/Models/SetVolumeVolumeParameter";

persistent actor {

    transient let apiConfig = {
        baseUrl = "http://192.168.178.42/YamahaExtendedControl/v1";
        accessToken = null;
        max_response_bytes = null;
        transform = null;
        is_replicated = null;
        cycles = 30_000_000_000;
    };

    transient let powerApi = PowerApi(apiConfig);
    transient let zoneApi = ZoneApi(apiConfig);

    /// Test sequence: power on, raise volume in 5-increments to 30%, power off
    public func testYamahaSequence() : async Text {
        Debug.print("Starting Yamaha MusicCast test sequence");

        // 1. Power on
        Debug.print("1. Powering on...");
        let _ = await powerApi.setPower("main", #true_);
        Debug.print("   ✓ Power on");

        // 2. Raise volume from 5 to 30 in increments of 5
        Debug.print("2. Raising volume from 5% to 30%...");
        for (volume in [5, 10, 15, 20, 25, 30].vals()) {
            Debug.print("   Setting volume to " # Int.toText(volume));
            ignore await zoneApi.setVolume("main", #one_of_0(volume), 0);
        };
        Debug.print("   ✓ Volume raised to 30%");

        // 3. Power off (standby)
        Debug.print("3. Powering off...");
        let _ = await powerApi.setPower("main", #standby);
        Debug.print("   ✓ Power off (standby)");

        Debug.print("Test sequence completed successfully!");
        "SUCCESS: Test sequence completed - powered on, raised volume to 30%, powered off"
    };
}
