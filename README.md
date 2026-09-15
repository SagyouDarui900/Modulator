# AviUtl2 Modulator

AviUtl2用のModulatorスクリプトです。画像の各行または各列を走査し、輝度の累積値に応じて白線・黒線を描画します。

## 概要

元のAviUtl向け`Modulator.anm`および`Modulator.dll`を参考に、AviUtl2用のスクリプトモジュールとして移植しています。

本版ではC++のスクリプトモジュールで各行・各列を一方向に1回だけ走査します。そのため、処理量は画像のピクセル数に対して線形です。

## 導入方法

次のファイルをAviUtl2のスクリプトフォルダへコピーします。

- `Modulator.anm2`
- `Modulator.mod2`

コピー後、AviUtl2の「キャッシュを破棄」を実行するか、AviUtl2を再起動してください。

## 使い方

1. 対象オブジェクトにアニメーション効果を追加します。
2. `Modulator`を選択します。
3. 方向、スケール、描画数、間隔、線幅などを調整します。

### 設定項目

| 項目 | 内容 |
| --- | --- |
| ｽｹｰﾙ | 輝度累積のスケール |
| 描画数 | 1つの束に含める線の数 |
| 間隔数 | 線の束と次の束の間隔 |
| 幅(px) | 線幅 |
| 反転 | 輝度の判定を反転 |
| 方向 | 左から右、右から左、上から下、下から上 |
| 閾値 | 線を描画する輝度累積の閾値 |
| 透明度(白) | 白線の透明度 |
| 透明度(黒) | 黒線の透明度 |

## ファイル構成

| ファイル | 内容 |
| --- | --- |
| `Modulator.anm2` | AviUtl2用のアニメーション効果 |
| `Modulator.mod2` | CPU処理を行うスクリプトモジュール |
| `Modulator.cpp` | スクリプトモジュールのソースコード |
| `build-ModulatorCPU.ps1` | `.mod2`のビルドスクリプト |
| `ModulatorCPU_LICENSE.txt` | 元実装のMIT License |

## 実装と最適化

本版は次の方針で処理しています。

- 行または列を1回だけ走査
- CPU側で累積状態を保持し、ピクセルごとの再走査を行わない
- 画像の追加コピーや作業用バッファを作成しない
- `getpixeldata()`と`putpixeldata()`は各1回のみ実行
- 輝度計算の除算係数を行単位で事前計算
- 白線・黒線の画素値を行単位で作成し、画素ごとの再計算を削減

計算量は`O(width × height)`、追加メモリは定数です。画像データの取得・書き戻しに伴うVRAM転送はAviUtl2のAPI上必要な処理です。

## ビルド

Visual Studio Build Toolsなど、`cl.exe`を利用できる環境で実行します。

```powershell
.\build-ModulatorCPU.ps1
```

ビルドスクリプトは`Documents`以下から`aviutl2_sdk`を検索し、`Modulator.mod2`を生成します。

## 参考・ライセンス

元実装:

- [Modulator - Aodaruma](https://github.com/Aodaruma/Modulator)

元実装の著作権表示:

```text
Copyright (c) 2022 Aodaruma
Licensed under the MIT License.
```

詳細は`ModulatorCPU_LICENSE.txt`を参照してください。

本移植版は元実装を参考に、生成AIを利用してAviUtl2向けに作成・調整したものです。
