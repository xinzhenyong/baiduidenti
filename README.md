
# react-native-1ziton-bdidentifi
# 百度银行卡号码识别组件
## Getting started

`$ npm install @1ziton/react-native-bdidentifi --save`

### Mostly automatic installation

`$ react-native link @1ziton/react-native-bdidentifi`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-bdidentifi` and add `RNBdidentifi.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNBdidentifi.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import com.ziton.bdidentifi.BankPhotoReactPackage;` to the imports at the top of the file
  - Add `new BankPhotoReactPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-bdidentifi'
  	project(':react-native-bdidentifi').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-bdidentifi/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-bdidentifi')
  	```


## Usage
```javascript
import {
  NativeModules
} from 'react-native';
const { BankPhoto } = NativeModules;
```
     if (Platform.OS === 'android') {
      BankPhoto.regist('yourak', 'yoursk');
      BankPhoto.photo()
        .then((result) => {
          const bankEntity = JSON.parse(result);
          this.setState({
            bankCode: bankEntity.BankCardNumber,//银行卡号
            bankName: bankEntity.BankName,//银行卡名称
            bankLineNum: bankEntity.BankCardType//银行行号
          });
        })
        .catch((error) => {
          this.setState({
            result: JSON.parse(error)
          });
        });
    } 
```