#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>

#include <algorithm>

#include "filter2.h"
#include "module2.h"

namespace {

using Pixel = PIXEL_RGBA;

void process_line(
    Pixel* pixels,
    int length,
    int step,
    double omega,
    double phase,
    int drawing_count,
    int interval_count,
    int line_width,
    bool invert,
    int opacity_max,
    int opacity_min
) {
    const Pixel white_pixel = {
        255, 255, 255, static_cast<unsigned char>(opacity_max)
    };
    const Pixel black_pixel = {
        0, 0, 0, static_cast<unsigned char>(opacity_min)
    };
    const double inverse_omega = 1.0 / omega;
    double luminance_sum = 0.0;
    int draw_pixels = 0;
    int remaining_drawing = drawing_count;
    int remaining_interval = 0;

    for (int i = 0, index = step > 0 ? 0 : length - 1;
         i < length;
         ++i, index += step) {
        Pixel& pixel = pixels[index];
         const int luminance = (pixel.r + pixel.g + pixel.b) / 3;
         luminance_sum += invert
             ? luminance * inverse_omega
             : (256 - luminance) * inverse_omega;

        if (luminance_sum >= phase) {
            luminance_sum = 0.0;
            if (remaining_interval == 0 && remaining_drawing == 0) {
                remaining_drawing = drawing_count;
                remaining_interval = interval_count;
            } else if (remaining_interval == 0 && remaining_drawing > 0) {
                draw_pixels = line_width;
                --remaining_drawing;
            } else {
                --remaining_interval;
            }
        }

        if (draw_pixels > 0) {
            pixel = white_pixel;
            --draw_pixels;
        } else {
            pixel = black_pixel;
        }
    }
}

void main(SCRIPT_MODULE_PARAM* param) {
    if (param->get_param_num() != 12) {
        param->set_error("main expects 12 arguments");
        return;
    }

    auto* pixels = static_cast<Pixel*>(param->get_param_data(0));
    const int width = param->get_param_int(1);
    const int height = param->get_param_int(2);
    const double omega = std::max(0.25, param->get_param_double(3));
    const double phase = std::clamp(param->get_param_double(4), 0.0, 256.0);
    const int drawing_count = std::max(0, param->get_param_int(5));
    const int interval_count = std::max(0, param->get_param_int(6));
    const int line_width = std::max(0, param->get_param_int(7));
    const int direction = param->get_param_int(8);
    const bool invert = param->get_param_boolean(9);
    const int opacity_max = std::clamp(param->get_param_int(10), 0, 255);
    const int opacity_min = std::clamp(param->get_param_int(11), 0, 255);

    if (!pixels || width <= 0 || height <= 0) {
        param->set_error("invalid image data or image size");
        return;
    }

    const auto process_horizontal = [&](bool reverse) {
        for (int y = 0; y < height; ++y) {
            process_line(
                pixels + y * width,
                width,
                reverse ? -1 : 1,
                omega,
                phase,
                drawing_count,
                interval_count,
                line_width,
                invert,
                opacity_max,
                opacity_min
            );
        }
    };

    const auto process_vertical = [&](bool reverse) {
        for (int x = 0; x < width; ++x) {
            process_line(
                pixels + x,
                height,
                reverse ? -width : width,
                omega,
                phase,
                drawing_count,
                interval_count,
                line_width,
                invert,
                opacity_max,
                opacity_min
            );
        }
    };

    switch (direction) {
    case 1:
        process_horizontal(true);
        break;
    case 2:
        process_vertical(false);
        break;
    case 3:
        process_vertical(true);
        break;
    default:
        process_horizontal(false);
        break;
    }
}

SCRIPT_MODULE_FUNCTION functions[] = {
    {L"main", main},
    {nullptr, nullptr},
};

SCRIPT_MODULE_TABLE module = {
    L"Modulator CPU module for AviUtl2",
    functions,
};

} // namespace

extern "C" __declspec(dllexport) bool InitializePlugin(DWORD) {
    return true;
}

extern "C" __declspec(dllexport) void UninitializePlugin() {
}

extern "C" __declspec(dllexport) SCRIPT_MODULE_TABLE* GetScriptModuleTable() {
    return &module;
}
