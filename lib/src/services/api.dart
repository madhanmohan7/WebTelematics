class BaseURLConfig {

  static const String ipAddress = "34.47.242.135";
  
  static const String speedApiURL = "http://$ipAddress:3000/telematics/latest-speed/";

  static const String rssiApiURL = "http://$ipAddress:3000/telematics/signal-strength/";

  static const String batterySOCApiURL = "http://$ipAddress:3000/telematics/latest-soc/";

  static const String accelApiURL = "http://$ipAddress:3000/telematics/latest-accel/";

  static const String gyroApiURL = "http://$ipAddress:3000/telematics/latest-gyro/";

  static const String locationApiURL = "http://$ipAddress:3000/telematics/latest-location/";

  //RAW CAN DATA APIs
  static const String vehicleInfoOneApiURL = "http://$ipAddress:3000/telematics/vehicle-info1/";
  static const String driveInfoApiURL = "http://$ipAddress:3000/telematics/drive-info/";
  static const String vehicleInfoTwoApiURL = "http://$ipAddress:3000/telematics/vehicle-info2/";
  static const String diagnosisApiURL = "http://$ipAddress:3000/telematics/diagnosis/";
  static const String odoApiURL = "http://$ipAddress:3000/telematics/odo/";
  static const String bmsApiURL = "http://$ipAddress:3000/telematics/bms/";
  static const String epsOneApiURL = "http://$ipAddress:3000/telematics/eps1/";
  static const String epsTwoApiURL = "http://$ipAddress:3000/telematics/eps2/";



}
