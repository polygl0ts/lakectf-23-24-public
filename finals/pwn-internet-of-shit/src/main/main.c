#include <string.h>

#include "driver/i2c.h"
#include "esp_err.h"
#include "esp_event.h"
#include "esp_lcd_panel_io.h"
#include "esp_lcd_panel_ops.h"
#include "esp_lcd_panel_vendor.h"
#include "esp_log.h"
#include "esp_lvgl_port.h"
#include "esp_mac.h"
#include "esp_netif.h"
#include "esp_netif_net_stack.h"
#include "esp_timer.h"
#include "esp_wifi.h"
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "freertos/task.h"
#include "lvgl.h"
#include "lwip/err.h"
#include "lwip/inet.h"
#include "lwip/netdb.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include "nvs_flash.h"

/* AP configuration */
#define ESP_WIFI_AP_SSID   CONFIG_ESP_WIFI_AP_SSID
#define ESP_WIFI_AP_PASSWD CONFIG_ESP_WIFI_AP_PASSWORD
#define ESP_WIFI_CHANNEL   CONFIG_ESP_WIFI_AP_CHANNEL
#define MAX_STA_CONN       CONFIG_ESP_MAX_STA_CONN_AP
/* TCP Server configuration */
#define PORT               CONFIG_PORT
#define KEEPALIVE_IDLE     CONFIG_KEEPALIVE_IDLE
#define KEEPALIVE_INTERVAL CONFIG_KEEPALIVE_INTERVAL
#define KEEPALIVE_COUNT    CONFIG_KEEPALIVE_COUNT
/* I2C/Display configuration for SSD1306 OLEDs */
#define I2C_HOST        0
#define I2C_HW_ADDR     0x3C
#define I2C_PIN_NUM_SDA CONFIG_SDA_GPIO
#define I2C_PIN_NUM_SCL CONFIG_SCL_GPIO
#define I2C_PIN_NUM_RST -1
#define I2C_CLOCK_HZ    (400 * 1000)
#define OLED_H_RES      128
#define OLED_V_RES      64
#define OLED_CMD_BITS   8
#define OLED_PARAM_BITS 8

static const char flag[256] = CONFIG_FLAG;
static const char TAG[]     = "IoS";
static const char welcome[] =
    "        ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⠀⠀⠀⠀⠀⠀⢿⣇⣀⠀⠀⠀⠀⠀⠀\n"
    "⠀⠀⠀⠀⠀⠀⠀⣠⡶⠿⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⣇⠀⠀⠀⠀⠀⠀⢻⣿⠁⠀⠀⠀⠀⠀⠘⢷⡄⠀⠀⠀⠀⠀ \n"
    "⠐⠴⣗⣦⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⠇⠀⠀⢠⣶⠟⠛⠉⠀⠀⠀⢠⡄⠀⠀⠈⣿⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⠀⠀⠀⠘⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠉⠀⠀⠀⠸⣧⠀⠀⠀⠀⠀⢀⣼⠇⠀⢀⣼⠏⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠘⣷⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣆⠀⠀⠀⠀⢹⣷⠀⠀⠀⠀⣿⠁⠀⠠⣏⡀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⢠⡘⠀⠀⠀⢘⡇⠀⠀⠀⠀⠀⠱⢄⠀⠀⠀⠘⡆⠀⠀⢰⡟⠁⠀⠀⠀⠀⠹⣷⡄⠀⠙⢦⡀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⢸⠇⠀⠀⢀⡾⠃⠀⠀⠀⠀⠀⠀⡶⣤⠀⠈⠁⠀⠀⠀⠘⣗⠀⠀⠀⠀⠀⠀⢈⡿⠀⠀⠀⠃⠀⠀⢀⠀⠀ \n"
    "⠀⠀⠀⢠⠟⠀⠀⠀⡏⠀⠀⠀⠀⠀⠀⠀⣰⠃⢸⡀⠀⠀⠀⠀⠀⠀⣸⠀⠀⠀⠀⢀⡾⠋⠀⠀⠀⠀⠀⠰⠤⠿⠒⠂ \n"
    "⠀⠀⠀⣞⠀⠀⠀⢸⡇⠀⠀⠀⠀⣠⡴⠟⠁⠀⠈⠳⠦⣤⣀⠀⠀⠀⠁⠀⠀⠀⠀⢸⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠹⠀⠀⠀⠀⠧⠀⠀⠀⢰⡟⠀⠀⠀⠐⠼⢟⣲⡐⠈⣻⣤⣤⣀⠀⠀⠀⠀⠀⠙⢶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣇⠐⠀⢀⠀⠀⠀⠀⡉⠉⠉⢠⡘⠙⣿⣦⡀⠀⠀⠀⠰⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣿⣦⡀⠈⠐⠀⠄⠀⠀⠀⠀⠀⣀⣀⢈⠘⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⡾⠋⠁⣠⠌⠉⠓⠒⠀⠀⠀⠀⠐⠊⠊⠇⠿⠀⣀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⠀⠀⠀⠀⣼⠯⣷⡀⡜⢡⠆⠰⠂⠀⠀⠀⠀⠒⠦⠄⠌⠙⠲⢻⠉⡿⢶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⠀⠀⠀⠀⣿⣾⠟⢠⠇⢩⠃⠀⠀⠀⠀⠀⠀⠤⠃⠀⠀⠀⠀⠀⠹⣄⠀⡈⠙⣷⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⠀⢀⣴⠟⡋⠁⠀⠀⠀⠀⠀⠀⣰⠓⡀⠠⠀⠀⠀⠀⠀⠀⠀⠀⢀⡈⡆⠳⣌⢸⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠀⣰⡟⠱⠡⠃⠐⠂⡄⠀⠀⠠⠄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠆⢹⣴⣀⣳⣷⣶⠾⠟⠛⢷⣄⠀⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⢰⡟⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠉⠉⣉⡙⡛⠛⠛⠛⠛⠋⠉⠉⠀⠀⠀⢣⡑⠈⢻⡆⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⢸⡇⢹⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠓⠁⠀⠀⡀⢰⢠⠀⡆⠀⠆⠀⡄⢄⢶⠼⣿⠀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⠹⣷⡀⠘⡟⡆⡄⡀⠀⠀⠀⢀⠀⠀⠰⠀⠀⠀⠀⠐⣶⠄⡇⠾⠘⠀⢉⡄⢠⢧⢧⢸⠀⣰⡟⢀⠀⠀⠀⠀⠀ \n"
    "⠀⠀⠀⢀⣼⣷⡄⠀⣡⠁⢀⠈⡀⠀⠈⠐⠰⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠀⠃⠘⠢⠘⠊⢈⣡⣴⠟⡠⠋⡰⠃⡄⠀⠀ \n"
    "⠀⠀⣸⠕⢋⡽⠻⣶⣅⣇⠈⠰⠁⡇⠄⢰⠀⠀⠀⠀⠠⢠⣴⠠⠀⠃⠀⠀⢀⣀⣤⣴⡾⢟⡿⢣⠞⣡⠞⢀⡜⠁⠀⠀ \n"
    "⠀⠀⡴⠊⢁⡠⠚⠉⢉⡿⠛⢿⠷⢶⣶⣶⣦⣤⣤⣤⣤⣶⣶⣶⠶⡾⠿⠛⡿⠋⡩⠋⠠⠋⡴⢃⡜⠁⠀⠎⠀⠈⠀⠀ \n"
    "⠀⠀⠀⠀⠀⠀⠀⠘⠁⠀⠚⠁⠐⠋⠀⠊⠀⠘⠁⠀⠁⠀⠈⠀⠘⠁⠀⠀⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀ \n"
    "   The Internet is a shitty place but we're  \n"
    "    trying to make it nicer. Send us your    \n"
    "    message and we're gonna show it on the   \n"
    "                   screen!                   \n";
static const char wifi_ssid[32] = ESP_WIFI_AP_SSID;
static const char wifi_pw[64]   = ESP_WIFI_AP_PASSWD;
static lv_disp_t *disp          = NULL;

static void scroll_label(char *txt) {
    lv_obj_t *scr = lv_disp_get_scr_act(disp);
    lv_obj_clean(scr);
    lv_obj_t *label = lv_label_create(scr);
    lv_label_set_long_mode(label,
                           LV_LABEL_LONG_SCROLL_CIRCULAR); /* Circular scroll */
    lv_label_set_text(label, txt);
    /* Size of the screen (if you use rotation 90 or 270, please set
     * disp->driver->ver_res) */
    lv_obj_set_width(label, disp->driver->hor_res);
    lv_obj_align(label, LV_ALIGN_TOP_MID, 0, 0);
}

static void wifi_event_handler(void *arg, esp_event_base_t event_base,
                               int32_t event_id, void *event_data) {
    if (event_base == WIFI_EVENT && event_id == WIFI_EVENT_AP_STACONNECTED) {
        wifi_event_ap_staconnected_t *event =
            (wifi_event_ap_staconnected_t *)event_data;
        ESP_LOGI(TAG, "Station " MACSTR " joined, AID=%d", MAC2STR(event->mac),
                 event->aid);
    } else if (event_base == WIFI_EVENT
               && event_id == WIFI_EVENT_AP_STADISCONNECTED) {
        wifi_event_ap_stadisconnected_t *event =
            (wifi_event_ap_stadisconnected_t *)event_data;
        ESP_LOGI(TAG, "Station " MACSTR " left, AID=%d", MAC2STR(event->mac),
                 event->aid);
    }
}

/* Initialize soft AP */
esp_netif_t *wifi_init_softap(void) {
    esp_netif_t *esp_netif_ap = esp_netif_create_default_wifi_ap();

    wifi_config_t wifi_ap_config = {
        .ap =
            {
                .channel        = ESP_WIFI_CHANNEL,
                .max_connection = MAX_STA_CONN,
                .authmode       = WIFI_AUTH_WPA2_PSK,
                .pmf_cfg =
                    {
                        .required = false,
                    },
            },
    };
    strncpy((char *)wifi_ap_config.ap.ssid, wifi_ssid,
            sizeof(wifi_ap_config.ap.ssid));
    wifi_ap_config.ap.ssid[sizeof(wifi_ap_config.ap.ssid) - 1] = '\0';
    wifi_ap_config.ap.ssid_len = strlen((char *)wifi_ap_config.ap.ssid);
    strncpy((char *)wifi_ap_config.ap.password, wifi_pw,
            sizeof(wifi_ap_config.ap.password));

    if (strlen(ESP_WIFI_AP_PASSWD) == 0) {
        wifi_ap_config.ap.authmode = WIFI_AUTH_OPEN;
    }

    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_AP, &wifi_ap_config));

    ESP_LOGI(TAG, "wifi_init_softap finished. SSID:%s password:%s channel:%d",
             ESP_WIFI_AP_SSID, ESP_WIFI_AP_PASSWD, ESP_WIFI_CHANNEL);

    return esp_netif_ap;
}

static void robust_send(int sock, char *msg) {
    /* send() can return less bytes than supplied length.
     * Walk-around for robust implementation. */
    size_t len      = strlen(msg);
    int    to_write = len;
    while (to_write > 0) {
        int written = send(sock, msg + (len - to_write), to_write, 0);
        if (written < 0) {
            ESP_LOGE(TAG, "Error occurred during sending: errno %d", errno);
            /* Failed to transmit, giving up */
            return;
        }
        to_write -= written;
    }
}

static void recv_and_show(const int sock) {
    int  len            = 0;
    char rx_buffer[128] = {0};
    robust_send(sock, welcome);

    do {
        len = recv(sock, rx_buffer, 256, 0);
        if (len < 0) {
            ESP_LOGE(TAG, "Error occurred during receiving: errno %d", errno);
        } else if (len == 0) {
            ESP_LOGW(TAG, "Connection closed");
        } else {
            rx_buffer[len] = 0; /* Null-terminate whatever is received and treat
                                 * it like a string */
            ESP_LOGI(TAG, "Received %d bytes: %s", len, rx_buffer);

            /* Print the buffer to the screen */
            if (lvgl_port_lock(0)) {
                scroll_label(rx_buffer);
                lvgl_port_unlock();
            }

            robust_send(
                sock,
                "Received and printed your data to the screen, thanks!\n");
        }
    } while (len > 0);
}

static void tcp_server_task(void *pvParameters) {
    char               addr_str[128] = {0};
    int                keepAlive     = 1;
    int                keepIdle      = KEEPALIVE_IDLE;
    int                keepInterval  = KEEPALIVE_INTERVAL;
    int                keepCount     = KEEPALIVE_COUNT;
    struct sockaddr_in dest_addr = {.sin_addr   = {.s_addr = htonl(INADDR_ANY)},
                                    .sin_family = AF_INET,
                                    .sin_port   = htons(PORT)};

    int listen_sock = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    if (listen_sock < 0) {
        ESP_LOGE(TAG, "Unable to create socket: errno %d", errno);
        vTaskDelete(NULL);
        return;
    }
    int opt = 1;
    setsockopt(listen_sock, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

    ESP_LOGI(TAG, "Socket created");

    int err =
        bind(listen_sock, (struct sockaddr *)&dest_addr, sizeof(dest_addr));
    if (err != 0) {
        ESP_LOGE(TAG, "Socket unable to bind: errno %d", errno);
        close(listen_sock);
        vTaskDelete(NULL);
    }
    ESP_LOGI(TAG, "Socket bound, port %d", PORT);

    err = listen(listen_sock, 1);
    if (err != 0) {
        ESP_LOGE(TAG, "Error occurred during listen: errno %d", errno);
        close(listen_sock);
        vTaskDelete(NULL);
    }

    while (1) {
        ESP_LOGI(TAG, "Socket listening");

        struct sockaddr_in source_addr = {0};
        socklen_t          addr_len    = sizeof(source_addr);
        int                sock =
            accept(listen_sock, (struct sockaddr *)&source_addr, &addr_len);
        if (sock < 0) {
            ESP_LOGE(TAG, "Unable to accept connection: errno %d", errno);
            close(listen_sock);
            vTaskDelete(NULL);
        }

        /* Set tcp keepalive option */
        setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, &keepAlive, sizeof(int));
        setsockopt(sock, IPPROTO_TCP, TCP_KEEPIDLE, &keepIdle, sizeof(int));
        setsockopt(sock, IPPROTO_TCP, TCP_KEEPINTVL, &keepInterval,
                   sizeof(int));
        setsockopt(sock, IPPROTO_TCP, TCP_KEEPCNT, &keepCount, sizeof(int));
        /* Convert ip address to string */
        if (source_addr.sin_family == PF_INET) {
            inet_ntoa_r(((struct sockaddr_in *)&source_addr)->sin_addr,
                        addr_str, sizeof(addr_str) - 1);
        }
        ESP_LOGI(TAG, "Socket accepted ip address: %s", addr_str);

        recv_and_show(sock);

        shutdown(sock, 0);
        close(sock);
    }
}

void app_main(void) {
    /* Log flag for this instance */
    ESP_LOGI(TAG, "Flag for this instance: %s", flag);
    /* Initialize I2C */
    ESP_LOGI(TAG, "Initialize I2C bus");
    i2c_config_t i2c_conf = {
        .mode             = I2C_MODE_MASTER,
        .sda_io_num       = I2C_PIN_NUM_SDA,
        .scl_io_num       = I2C_PIN_NUM_SCL,
        .sda_pullup_en    = GPIO_PULLUP_ENABLE,
        .scl_pullup_en    = GPIO_PULLUP_ENABLE,
        .master.clk_speed = I2C_CLOCK_HZ,
    };
    ESP_ERROR_CHECK(i2c_param_config(I2C_HOST, &i2c_conf));
    ESP_ERROR_CHECK(i2c_driver_install(I2C_HOST, I2C_MODE_MASTER, 0, 0, 0));

    /* Initialize panel IO */
    ESP_LOGI(TAG, "Install panel IO");
    esp_lcd_panel_io_handle_t     io_handle = NULL;
    esp_lcd_panel_io_i2c_config_t io_config = {
        .dev_addr            = I2C_HW_ADDR,
        .control_phase_bytes = 1,              // According to SSD1306 datasheet
        .lcd_cmd_bits        = OLED_CMD_BITS,  // According to SSD1306 datasheet
        .lcd_param_bits      = OLED_CMD_BITS,  // According to SSD1306 datasheet
        .dc_bit_offset       = 6,              // According to SSD1306 datasheet
    };
    ESP_ERROR_CHECK(esp_lcd_new_panel_io_i2c((esp_lcd_i2c_bus_handle_t)I2C_HOST,
                                             &io_config, &io_handle));

    /* Initialize SSD1306 driver */
    ESP_LOGI(TAG, "Install SSD1306 panel driver");
    esp_lcd_panel_handle_t     panel_handle = NULL;
    esp_lcd_panel_dev_config_t panel_config = {
        .bits_per_pixel = 1,
        .reset_gpio_num = I2C_PIN_NUM_RST,
    };
    ESP_ERROR_CHECK(
        esp_lcd_new_panel_ssd1306(io_handle, &panel_config, &panel_handle));

    ESP_ERROR_CHECK(esp_lcd_panel_reset(panel_handle));
    ESP_ERROR_CHECK(esp_lcd_panel_init(panel_handle));
    ESP_ERROR_CHECK(esp_lcd_panel_disp_on_off(panel_handle, true));

    /* Initialize LVGL */
    ESP_LOGI(TAG, "Initialize LVGL");
    const lvgl_port_cfg_t lvgl_cfg = ESP_LVGL_PORT_INIT_CONFIG();
    lvgl_port_init(&lvgl_cfg);

    const lvgl_port_display_cfg_t disp_cfg = {
        .io_handle     = io_handle,
        .panel_handle  = panel_handle,
        .buffer_size   = OLED_H_RES * OLED_V_RES,
        .double_buffer = true,
        .hres          = OLED_H_RES,
        .vres          = OLED_V_RES,
        .monochrome    = true,
        .rotation =
            {
                .swap_xy  = false,
                .mirror_x = false,
                .mirror_y = false,
            },
    };
    disp = lvgl_port_add_disp(&disp_cfg);

    /* Rotate the screen */
    lv_disp_set_rotation(disp, LV_DISP_ROT_180);

    ESP_LOGI(TAG, "Display LVGL Scroll Text");
    /* Lock the mutex because LVGL APIs are not thread-safe */
    if (lvgl_port_lock(0)) {
        scroll_label("polygl0ts Internet of Shit");
        /* Release the mutex */
        lvgl_port_unlock();
    }

    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    /* Initialize NVS */
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES
        || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    /* Register Event handler */
    ESP_ERROR_CHECK(esp_event_handler_instance_register(
        WIFI_EVENT, ESP_EVENT_ANY_ID, &wifi_event_handler, NULL, NULL));

    /*Initialize WiFi */
    wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&cfg));

    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_AP));

    /* Initialize AP */
    ESP_LOGI(TAG, "ESP_WIFI_MODE_AP");
    strncpy(wifi_ssid, ESP_WIFI_AP_SSID, sizeof(wifi_ssid));
    strncpy(wifi_pw, ESP_WIFI_AP_PASSWD, sizeof(wifi_pw));
    esp_netif_t *esp_netif_ap = wifi_init_softap();

    /* Start WiFi */
    ESP_ERROR_CHECK(esp_wifi_start());

    /* Once the access point is up, start the TCP server */
    xTaskCreate(tcp_server_task, "tcp_server", 4096, NULL, 5, NULL);
}
