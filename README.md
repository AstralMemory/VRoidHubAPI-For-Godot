# VRoidHubWebAPIforGodot
 GodotEngineでVRoidHubWebAPIを使ったサンプル

 容量制限に引っかかったためandroidフォルダーを削除しました。Android用にビルドする際はAndroidエクスポートテンプレートをインストールし、Androidフォルダ内のpluginsフォルダに以下のファイルを入れてください。
ClipBoardPlugin : https://astralmemory.net:8081/share.cgi?ssid=f268951da719438694f5dcb23b1edf06

 使用したプラグイン 
  VRM Importer for 3D Avatars and MToon Shader : https://godotengine.org/asset-library/asset/2031

  動作 : https://youtu.be/hUyXJTTNMeY
  

注意点
使用する前にAssetLibからgodot-vrmをダウンロードしてください。上記の使用したプラグインというやつです。<br>
モデルをロードした後になぜかモデルが暗くなるためDirectionalLight3Dを設置しています。<br>
オンオフは親ノードであるModelLoaderのインスペクター中の Model Lightを切り替えてください。

<hr>

Change Log v1<br>
addonsフォルダーを削除しました。<br>
ボーンの関係上VRM1.0は非対応にしました。<br>
アニメーションテスト用のボタンを追加しました。

Change Log v2<br>
ModelListにお気に入り登録しているモデルの表示を追加しました。
モデルが読み込めなかったエラーを解消しました。
