# AviUtl2 Modulator

AviUtl2用のModulatorスクリプトです。画像の各行または各列を走査し、輝度の累積値に応じて白線・黒線を描画します。

## 概要

元のAviUtl向け`Modulator.anm`および`Modulator.dll`を参考に、AviUtl2用のスクリプトモジュールとして移植しています。

本版ではC++のスクリプトモジュールで各行・各列を一方向に1回だけ走査します。処理量は画像のピクセル数に対して線形です。さらに、行・列単位の独立性を活かしてOpenMPによるマルチスレッド並列処理を行っています。

## 導入方法

次のファイルをAviUtl2のスクリプトフォルダ（`ProgramData\aviutl2\Script\` またはそのサブフォルダ）へコピーします。

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
| スケール | 輝度累積のスケール |
| 描画数 | 1つの束に含める線の数 |
| 間隔数 | 線の束と次の束の間隔 |
| 幅(px) | 線幅 |
| 反転 | 輝度の判定を反転 |
| 方向 | 左から右、右から左、上から下、下から上 |
| 閾値 | 線を描画する輝度累積の閾値 |
| 透明度(白) | 白線の透明度 (0〜255) |
| 透明度(黒) | 黒線の透明度 (0〜255) |

## ファイル構成

| ファイル | 内容 |
| --- | --- |
| `Modulator.anm2` | AviUtl2用のアニメーション効果スクリプト |
| `Modulator.mod2` | CPU処理を行うスクリプトモジュール (ビルド成果物) |
| `Modulator.cpp` | スクリプトモジュールのC++ソースコード |
| `build-ModulatorCPU.ps1` | `.mod2`のビルドスクリプト |
| `Modulator_LICENSE.txt` | 元実装のMIT License |
| `LICENSE` | 本リポジトリのライセンス (MIT License) |

## 実装と最適化

本版は次の方針で高速化・最適化しています。

- **線形走査**: 行または列を1回だけ走査（計算量 $O(\text{width} \times \text{height})$、追加メモリは定数）
- **マルチスレッド並列処理**: 行単位・列単位の独立性を活かし、OpenMP（`#pragma omp parallel for`）により全CPUコアで並列処理
- **コンパイラ最適化**: `/O2`（最大速度最適化）、`/Oi`（組み込み関数インライン化）、ポインタ直接走査によるオーバーヘッド削減
- **ゼロコピー**: 画像の追加コピーや作業用バッファを作成せず、インプレースで画素を書き換え
- **事前計算**: 輝度計算の除算係数（`inverse_omega`）および白線・黒線ピクセルを事前に作成

## ビルド方法

Visual Studio Build Tools など `cl.exe` を利用できる環境で実行します。

```powershell
.\build-ModulatorCPU.ps1
```

ビルドスクリプトは自動的にVisual Studioのx64ビルド環境と`aviutl2_sdk`を検出し、最適化された `Modulator.mod2` を生成します。

## 参考・ライセンス

元実装:
- [Modulator - Aodaruma](https://github.com/Aodaruma/Modulator)

元実装の著作権表示:
```text
Copyright (c) 2022 Aodaruma
```

### AviUtl ExEdit2 Plugin SDK

`Modulator.cpp` は、AviUtl ExEdit2 Plugin SDKのヘッダーを使用してビルドしています。

```text
AviUtl ExEdit2 Plugin SDK
Copyright (c) 2025 Kenkun
Licensed under the MIT License.
```

SDKのライセンス全文は、SDKに付属する `license.txt` を参照してください。本配布物には AviUtl ExEdit2 Plugin SDK 本体のソースコードは含めていません。

### ライセンス

元実装のライセンス条件に従い、本移植版にも著作権表示とMIT Licenseを適用します。
ライセンス全文は [`LICENSE`](./LICENSE) および [`Modulator_LICENSE.txt`](./Modulator_LICENSE.txt) を参照してください。

Copyright (c) 2026 🈂️行 (Port for AviUtl2)  
Copyright (c) 2022 Aodaruma (Original implementation)  
