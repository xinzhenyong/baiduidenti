
# react-native-bdidentifi

## Getting started

`$ npm install react-native-bdidentifi --save`

### Mostly automatic installation

`$ react-native link react-native-bdidentifi`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-bdidentifi` and add `RNBdidentifi.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNBdidentifi.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.1ziton.bdidentifi.RNBdidentifiPackage;` to the imports at the top of the file
  - Add `new RNBdidentifiPackage()` to the list returned by the `getPackages()` method
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
      BankPhoto.photo()
        .then((result) => {
          const bankEntity = JSON.parse(result);
          this.setState({
            bankCode: bankEntity.BankCardNumber,
            bankName: bankEntity.BankName,
            bankLineNum: bankEntity.BankCardType
          });
        })
        .catch((error) => {
          this.setState({
            result: JSON.parse(error)
          });
        });
    } 