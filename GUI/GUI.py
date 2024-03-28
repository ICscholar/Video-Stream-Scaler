import time
from tkinter.ttk import *
from tkinter import *
import tkinter as tk
import datetime
import serial       # 导入模块
import serial.tools.list_ports
import threading
from tkinter import messagebox
from ttkbootstrap import Style
from PIL import Image, ImageTk

global UART                                         # 全局型式保存串口句柄
global RX_THREAD                                    # 全局型式保存串口接收函数
global gui                                          # 全局型式保存GUI句柄

tx_cnt = 0                                          # 发送字符数统计
rx_cnt = 0                                          # 接收字符数统计


def ISHEX(data):                                    # 判断输入字符串是否为十六进制
    if len(data) % 2:
        return False
    for item in data:
        if item not in '0123456789ABCDEFabcdef':    # 循环判断数字和字符
            return False
    return True


def uart_open_close(fun, com, bund):                # 串口打开关闭控制
    global UART
    global RX_THREAD

    if fun == 1:  # 打开串口
        try:
            UART = serial.Serial(com, bund, timeout=0.2)        # 提取串口号和波特率并打开串口
            if UART.isOpen():  # 判断是否打开成功
                lock = threading.Lock()
                RX_THREAD = UART_RX_TREAD('URX1', lock)   # 开启数据接收进程
                RX_THREAD.setDaemon(True)                       # 开启守护进程 主进程结束后接收进程也关闭 会报警告 不知道咋回事
                RX_THREAD.start()
                RX_THREAD.resume()
                return True
        except:
            return False
        return False
    else:  # 关闭串口
        print("关闭串口")
        RX_THREAD.pause()
        UART.close()        

def uart_tx(data, isHex=False):
    global UART
    try:
        if UART.isOpen():
            # 发送前判断串口状态 避免错误
            data_with_header_footer = "00" + data + "ff00"
            print("uart_send=" + data_with_header_footer)
            gui.tx_rx_cnt(tx=len(data_with_header_footer))  # 发送计数
            if isHex:
                # 十六进制发送
                data_bytes = bytes.fromhex(data_with_header_footer)
                for byte in data_bytes:
                    UART.write(byte.to_bytes(1, byteorder='big'))  # Send one byte at a time

    except Exception as e:
        # 错误返回
        print(e)
        messagebox.showinfo('错误', '发送失败')

class UART_RX_TREAD(threading.Thread):          # 数据接收进程
    global gui

    def __init__(self, name, lock):
        threading.Thread.__init__(self)
        self.mName = name
        self.mLock = lock
        self.mEvent = threading.Event()

    def run(self):  # 主函数
        print('开启数据接收\r')
        while True:
            self.mEvent.wait()
            self.mLock.acquire()
            if UART.isOpen():
                rx_buf = UART.read()
                if len(rx_buf) > 0:
                    rx_buf += UART.readall()  # 有延迟但不易出错
                    gui.tx_rx_cnt(rx=len(rx_buf))

                    print('收到hex数据', rx_buf.hex().upper())
                    gui.txt_rx.insert(END, rx_buf.hex().upper())

            self.mLock.release()

    def pause(self):  # 暂停
        self.mEvent.clear()

    def resume(self):  # 恢复
        self.mEvent.set()


# ---------------------------------------------GUI---------------------------------------------- #
class GUI:
    def __init__(self):
        self.root = Tk()
        self.root.title('易灵思串口调试助手')  # 窗口名称
        self.root.geometry("1020x360")  # 尺寸位置
        self.interface()
        Style(
            theme='pulse')  # 主题修改 可选['cyborg', 'journal', 'darkly', 'flatly' 'solar', 'minty', 'litera', 'united', 'pulse', 'cosmo', 'lumen', 'yeti', 'superhero','sandstone']

    def set_enlarge_narrow(self, value):
            self.enlarge_narrow = value
    def interface(self):
        """界面编写位置"""
        # -------------------------------- LEFT IMAGE ------------------------------- #
        self.fr0 = Frame(self.root)
        self.fr0.place(x=0, y=0, width=153, height=360)

        path_Left_Image = "./Image/Left_1200x510.png"
        image_Left_Image = Image.open(path_Left_Image).resize((153, 360), Image.Resampling.LANCZOS)
        photo_Left_Image = ImageTk.PhotoImage(image_Left_Image)

        self.Left_Image = Label(self.fr0, image=photo_Left_Image)
        self.Left_Image.image = photo_Left_Image
        self.Left_Image.place(x=0, y=0, width=153, height=360)


        # --------------------------------操作区域(frame_1)------------------------------ #
        self.fr1 = Frame(self.root)
        self.fr1.place(x=0+153, y=0, width=180, height=360)  # 区域1位置尺寸

        self.lb1 = Label(self.fr1, text='端口号：', font="微软雅黑", fg='red')  # 点击可刷新
        self.lb1.place(x=0, y=5, width=100, height=35)

        self.var_cb1 = StringVar()
        self.comb1 = Combobox(self.fr1, textvariable=self.var_cb1)
        self.comb1['values'] = list(serial.tools.list_ports.comports())  # 列出可用串口
        # self.comb1.current(0)  # 设置默认选项 0开始
        self.comb1.place(x=10, y=40, width=150, height=30)
        com = list(serial.tools.list_ports.comports())

        print('**********可用串口***********')
        for i in range(0, len(com)):
            print(com[i])
        print('***************************')

        self.lb2 = Label(self.fr1, text='波特率：')
        self.comb2 = Combobox(self.fr1, values=['115200'], state='readonly')
        self.comb2.current(0)  # 设置默认选项 115200
        self.lb2.place(x=5, y=75, width=60, height=20)
        self.comb2.place(x=10, y=100, width=100, height=25)

        self.var_bt1 = StringVar()
        self.var_bt1.set("打开串口")
        self.btn1 = Button(self.fr1, textvariable=self.var_bt1, command=self.uart_opn_close)  # 绑定 uart_opn_close 方法
        self.btn1.place(x=10, y=140, width=60, height=30)

        self.var_cs = IntVar()  # 定义返回类型
        self.rd1 = Radiobutton(self.fr1, text="邻近域", variable=self.var_cs, value=1, command=self.txt_clr)           # 选择后清除显示内容
        self.rd2 = Radiobutton(self.fr1, text="双线性插值", variable=self.var_cs, value=0, command=self.txt_clr)
        self.rd1.place(x=5, y=180, width=60, height=30)
        self.rd2.place(x=5, y=210, width=80, height=30)

        self.btn3 = Button(self.fr1, text='清空', command=self.txt_clr)  # 绑定清空方法
        self.btn3.place(x=10, y=260, width=60, height=30)
        self.btn4 = Button(self.fr1, text='保存', command=self.savefiles)  # 绑定保存方法
        self.btn4.place(x=100, y=260, width=60, height=30)

        self.btn6 = Button(self.fr1, text='发送', command=lambda: [self.uart_send(), self.fetch_and_combine()])
        self.btn6.place(x=10, y=315, width=150, height=40)

        # -------------------------------参数区域(frame_2)------------------------------- #
        self.fr2 = Frame(self.root)  # 区域1 容器  relief   groove=凹  ridge=凸
        self.fr2.place(x=180 + 140, y=0, width=360, height=360)  # 区域1位置尺寸

        self.enlarge_narrow = 0  # 初始值为0

        self.comb_algorithm = Combobox(self.fr2, values=['请选择你的模式', '放大模式', '缩小模式'], state='readonly')
        self.comb_algorithm.current(0)

        self.comb_algorithm.bind('<<ComboboxSelected>>', lambda event: self.combobox_mode_select(comb_algorithm=self.comb_algorithm))
        self.comb_algorithm.place(x=20, y=0, width=150, height=30)

# ------------------------------ZOOM OUT----------------------------- #
        self.ZoomOut = Label(self.fr2, text="放大模式", bg="yellow", anchor='w')
        self.ZoomOut.place(x=20, y=33, width=60, height=29)

        self.start_x_label = Label(self.fr2, text="起始点横坐标", bg="yellow", anchor='w')
        self.start_x_label.place(x=20, y=66, width=80, height=29)
        self.x_left = Text(self.fr2, state=tk.NORMAL, bg='white')
        self.x_left.insert(tk.END, "0")
        self.x_left.place(x=285, y=66, width=45, height=29)
        self.x_left.bind("<KeyRelease>", self.update_scale_from_text)
        self.start_x_scale = tk.Scale(self.fr2, from_=0, to=1919, orient=tk.HORIZONTAL,
                                      command=lambda value:self.update_text_from_scale(value,self.x_left))
        self.start_x_scale.place(x=100, y=73, width=180, height=15)

        self.start_y_label = Label(self.fr2, text="起始点纵坐标", bg="yellow", anchor='w')
        self.start_y_label.place(x=20, y=99, width=80, height=29)
        self.y_up = Text(self.fr2, state=tk.NORMAL, bg='white')
        self.y_up.insert(tk.END, "0")
        self.y_up.place(x=285, y=99, width=45, height=29)
        self.y_up.bind("<KeyRelease>", self.update_scale_from_text)

        self.start_y_scale = tk.Scale(self.fr2, from_=0, to=1079, orient=tk.HORIZONTAL,
                                      command=lambda value: self.update_text_from_scale(value, self.y_up))
        self.start_y_scale.place(x=100, y=106, width=180, height=15)

        self.end_x_label = Label(self.fr2, text="终止点横坐标", bg="yellow", anchor='w')
        self.end_x_label.place(x=20, y=132, width=80, height=29)
        self.x_right = Text(self.fr2, state=tk.NORMAL, bg='white')
        self.x_right.insert(tk.END, "1")
        self.x_right.place(x=285, y=132, width=45, height=29)
        self.x_right.bind("<KeyRelease>", self.update_scale_from_text)
        self.end_x_scale = tk.Scale(self.fr2, from_=int(self.x_left.get("1.0", tk.END).strip()), to=1920, orient=tk.HORIZONTAL,
                                      command=lambda value: self.update_text_from_scale(value, self.x_right))
        self.end_x_scale.place(x=100, y=139, width=180, height=15)

        self.end_y_label = Label(self.fr2, text="终止点纵坐标", bg="yellow", anchor='w')
        self.end_y_label.place(x=20, y=165, width=80, height=29)
        self.y_down = Text(self.fr2, state=tk.NORMAL, bg='white')
        self.y_down.insert(tk.END, "1")
        self.y_down.place(x=285, y=165, width=45, height=29)
        self.y_down.bind("<KeyRelease>", self.update_scale_from_text)

        self.end_y_scale = tk.Scale(self.fr2, from_=0, to=1080, orient=tk.HORIZONTAL,
                                      command=lambda value: self.update_text_from_scale(value, self.y_down))
        self.end_y_scale.place(x=100, y=172, width=180, height=15)

# ------------------------------ZOOM OUT----------------------------- #
        self.ZoomIn = Label(self.fr2, text="缩小模式", bg="yellow", anchor='w')
        self.ZoomIn.place(x=20, y=198+10, width=60, height=29)

        self.narrow_w_label = Label(self.fr2, text="缩小后宽度", bg="yellow", anchor='w')
        self.narrow_w_label.place(x=20, y=231+10, width=80, height=29)
        self.narraw_width = Text(self.fr2, state=tk.NORMAL, bg='white')
        self.narraw_width.insert(tk.END, "1")
        self.narraw_width.place(x=285, y=231+10, width=45, height=29)
        self.narraw_width.bind("<KeyRelease>", self.update_scale_from_text)
        self.narrow_w_scale = tk.Scale(self.fr2, from_=int(self.x_left.get("1.0", tk.END).strip()), to=1920,
                                    orient=tk.HORIZONTAL,
                                    command=lambda value: self.update_text_from_scale(value, self.narraw_width))
        self.narrow_w_scale.place(x=100, y=238+10, width=180, height=15)

        self.narrow_h_label = Label(self.fr2, text="缩小后高度", bg="yellow", anchor='w')
        self.narrow_h_label.place(x=20, y=264+10, width=80, height=29)
        self.narraw_height = Text(self.fr2, state=tk.NORMAL, bg='white')
        self.narraw_height.insert(tk.END, "1")
        self.narraw_height.place(x=285, y=264+10, width=45, height=29)
        self.narraw_height.bind("<KeyRelease>", self.update_scale_from_text)
        self.narrow_h_scale = tk.Scale(self.fr2, from_=int(self.x_left.get("1.0", tk.END).strip()), to=1080,
                                       orient=tk.HORIZONTAL,
                                       command=lambda value: self.update_text_from_scale(value, self.narraw_height))
        self.narrow_h_scale.place(x=100, y=271+10, width=180, height=15)

        # self.toggle_edit([], [self.x_right, self.x_left, self.y_up, self.y_down, self.narraw_width, self.narraw_height],
        #                  [], [self.start_x_scale, self.start_y_scale, self.end_x_scale, self.end_y_scale,
        #                       self.narrow_h_scale, self.narrow_w_scale])

        # ---------------------------------------------------------------------------- #
        # 收发字符监控
        self.lb3 = Label(self.fr2, text='接收:0    发送:0', bg="yellow", anchor='w')
        self.lb3.place(relheight=0.05, relwidth=0.3, relx=0.045, rely=0.94)

        # 时钟实现
        self.lb4 = Label(self.fr2, text=' ', anchor='w', relief=GROOVE)
        self.lb4.place(relheight=0.05, relwidth=0.1, relx=0.8, rely=0.94)

        # -------------------------------返回信息区域(frame_3)------------------------------- #
        self.fr3 = Frame(self.root)  # 区域1 容器  relief   groove=凹  ridge=凸
        self.fr3.place(x=180+120+360, y=0, width=180, height=360)  # 区域1位置尺寸

        self.txt_rx = Text(self.fr3)
        self.txt_rx.place(relheight=0.9, relwidth=0.9, relx=0.05, rely=0.05)  # 比例计算控件尺寸和位置

        # --------------------------- IMAGE RIGHT(frame_4) --------------------------- #
        self.fr4 = Frame(self.root)  # 区域1 容器  relief   groove=凹  ridge=凸
        self.fr4.place(x=540+120+180, y=0, width=180, height=360)  # 区域1位置尺寸

        path_Right_Image = ".\Image\Right_1200x600.png"
        image_Right_Image = Image.open(path_Right_Image).resize((180, 360), Image.Resampling.LANCZOS)
        photo_Right_Image = ImageTk.PhotoImage(image_Right_Image)

        self.Right_Image = Label(self.fr4, image=photo_Right_Image)
        self.Right_Image.image = photo_Right_Image
        self.Right_Image.place(x=0, y=0, width=180, height=360)

    # -----------------------------------方法---------------------------------- #
    def update_text_from_scale(self, value, text_widget):
        text_widget.delete("1.0", tk.END)
        text_widget.insert(tk.END, value)
        if text_widget == self.x_left:
            start_value = int(value)
            end_value = int(self.x_right.get("1.0", tk.END).strip())
            if start_value >= end_value:
                new_end_value = start_value + 1
                self.x_right.delete("1.0", tk.END)
                self.x_right.insert(tk.END, str(new_end_value))
                self.end_x_scale.set(new_end_value)
        if text_widget == self.y_up:
            start_value = int(value)
            end_value = int(self.y_down.get("1.0", tk.END).strip())
            if start_value >= end_value:
                new_end_value = start_value + 1
                self.y_down.delete("1.0", tk.END)
                self.y_down.insert(tk.END, str(new_end_value))
                self.end_y_scale.set(new_end_value)

    def update_scale_from_text(self, event=None):
        # Get the widget that is currently focused
        focused_widget = self.fr2.focus_get()

        # Check which text widget is focused and update the corresponding scale widget
        if focused_widget == self.x_left:
            try:
                value = int(self.x_left.get("1.0", tk.END).strip())
                self.start_x_scale.set(value)
                if int(self.x_left.get("1.0", tk.END).strip()) >= int(self.x_right.get("1.0", tk.END).strip()):
                    self.end_x_scale.set(value+1)
            except ValueError:
                pass  # Optionally handle invalid input here
        if focused_widget == self.x_right:
            try:
                value = int(self.x_right.get("1.0", tk.END).strip())
                self.end_x_scale.set(value)
            except ValueError:
                pass  # Optionally handle invalid input here
        if focused_widget == self.y_up:
            try:
                value = int(self.y_up.get("1.0", tk.END).strip())
                self.start_y_scale.set(value)
                if int(self.y_up.get("1.0", tk.END).strip()) >= int(self.y_down.get("1.0", tk.END).strip()):
                    self.end_y_scale.set(value+1)
            except ValueError:
                pass  # Optionally handle invalid input here
        if focused_widget == self.y_down:
            try:
                value = int(self.y_down.get("1.0", tk.END).strip())
                self.end_y_scale.set(value)
            except ValueError:
                pass  # Optionally handle invalid input here

    # 模式选择
    def combobox_mode_select(self, comb_algorithm):
        selected_state = comb_algorithm.get()
        if selected_state == '请选择你的模式':
            self.toggle_edit([],[self.x_right, self.x_left, self.y_up, self.y_down,self.narraw_width, self.narraw_height], [], [self.start_x_scale, self.start_y_scale, self.end_x_scale, self.end_y_scale, self.narrow_h_scale, self.narrow_w_scale])
        elif selected_state == '放大模式':
            self.toggle_edit([self.x_right, self.x_left, self.y_up, self.y_down], [self.narraw_width, self.narraw_height], [self.start_x_scale, self.start_y_scale, self.end_x_scale, self.end_y_scale], [self.narrow_h_scale, self.narrow_w_scale])
            self.set_enlarge_narrow(0)
        elif selected_state == '缩小模式':
            self.toggle_edit([self.narraw_width, self.narraw_height],[self.x_right, self.x_left, self.y_up, self.y_down], [self.narrow_h_scale, self.narrow_w_scale], [self.start_x_scale, self.start_y_scale, self.end_x_scale, self.end_y_scale])
            self.set_enlarge_narrow(1)

    # 锁定不需输入的文本框
    def toggle_edit(self, list_en_text,list_di_text, list_en_scale, list_di_scale):
        for items_en_text in list_en_text:
            if items_en_text['state'] == tk.DISABLED:
                items_en_text.config(state=tk.NORMAL, bg='white')
            else:
                items_en_text.config(state=tk.NORMAL, bg='white')
        for items_di_text in list_di_text:
            if items_di_text['state'] == tk.NORMAL:
                items_di_text.config(state=tk.DISABLED, bg='grey')
                # items_di_text.config(bg='grey')
            else:
                items_di_text.config(state=tk.DISABLED, bg='grey')
                # items_di_text.config(bg='grey')
        for items_en_scale in list_en_scale:
            if items_en_scale['state'] == tk.DISABLED:
                items_en_scale.config(state=tk.NORMAL, bg='#412769')
            else:
                items_en_scale.config(state=tk.NORMAL, bg='#412769')
        for items_di_scale in list_di_scale:
            if items_di_scale['state'] == tk.NORMAL:
                items_di_scale.config(state=tk.DISABLED, bg='grey')
            else:
                items_di_scale.config(state=tk.DISABLED, bg='grey')

    def fetch_and_combine(self):
        # Fetching values from the Text widgets
        enlarge_narrow = self.enlarge_narrow
        if (enlarge_narrow == 0):
            x_right_val = self.x_right.get("1.0", "end-1c")
            x_left_val = self.x_left.get("1.0", "end-1c")
            y_up_val = self.y_up.get("1.0", "end-1c")
            y_down_val = self.y_down.get("1.0", "end-1c")
        else:
            x_right_val = self.narraw_width.get("1.0", "end-1c")
            y_down_val = self.narraw_height.get("1.0", "end-1c")
            x_left_val = "0"
            y_up_val = "0"
        var_cs=self.var_cs.get()

        try:
            x_right_val = int(x_right_val or 0, 10)
            x_left_val = int(x_left_val or 0, 10)
            y_up_val = int(y_up_val or 0, 10)
            y_down_val = int(y_down_val or 0, 10)
            # Ensure that the values are within the valid range
            if not (x_left_val < x_right_val and y_up_val < y_down_val):
                raise ValueError("Invalid range for values")
            x_right_val = hex(x_right_val)[2:]
            x_right_val = x_right_val.zfill(4)

            x_left_val = hex(x_left_val)[2:]
            x_left_val = x_left_val.zfill(4)

            y_up_val = hex(y_up_val)[2:]
            y_up_val = y_up_val.zfill(4)

            y_down_val = hex(y_down_val)[2:]
            y_down_val = y_down_val.zfill(4)

            # Combining the fetched values
            if (enlarge_narrow == 0):
                combined_string = f"{0}{enlarge_narrow}{x_left_val}{y_up_val}{x_right_val}{y_down_val}{0}{var_cs}"
            else:
                combined_string = f"{0}{enlarge_narrow}{x_right_val}{y_down_val}{0}{var_cs}"
            return combined_string
        except ValueError as e:
            messagebox.showinfo('错误', f'请重新输入有效数据: {e}')


    def gettim(self):  # 获取时间 未用
        timestr = time.strftime("%H:%M:%S")  # 获取当前的时间并转化为字符串
        self.lb4.configure(text=timestr)  # 重新设置标签文本
        # tim_str = str(datetime.datetime.now()) + '\n'
        # self.lb4['text'] = tim_str
        self.txt_rx.after(1000, self.gettim)  # 每隔1s调用函数 gettime 自身获取时间 GUI自带的定时函数

    def txt_clr(self):  # 清空显示
        self.txt_rx.delete(0.0, 'end')      # 清空文本框
        # self.x_right.delete(0.0, 'end')
        # self.x_left.delete(0.0, 'end')
        # self.y_up.delete(0.0, 'end')
        # self.y_down.delete(0.0, 'end')
        # self.algorithm.delete(0.0, 'end')# 清空文本框

    def uart_opn_close(self):               # 打开关闭串口
        if (self.var_bt1.get() == '打开串口'):
            if (uart_open_close(1, str(self.comb1.get())[0:5],
                                self.comb2.get()) == True):  # 传递下拉框选择的参数 COM号+波特率  【0:5】表示只提取COM号字符
                self.var_bt1.set('关闭串口')  # 改变按键内容
                self.txt_rx.insert(0.0, self.comb1.get() + ' 打开成功\r\n')  # 开头插入
            else:
                print("串口打开失败")
                messagebox.showinfo('错误', '串口打开失败')
        else:
            uart_open_close(0, 'COM1', 115200)  # 关闭时参数无效
            self.var_bt1.set('打开串口')

    def uart_send(self):  # 发送数据
        send_data = self.fetch_and_combine()
        # if self.ascii_hex_get():  # 字符发送
        #     uart_tx(send_data)
        # else:
        #     send_data = send_data.replace(" ", "").replace("\n", "0A").replace("\r", "0D")  # 替换空格和回车换行
        if (ISHEX(send_data) == False):
            messagebox.showinfo('错误', '请输入十六进制数')
            return
        uart_tx(send_data, True)

    def tx_rx_cnt(self, rx=0, tx=0):  # 发送接收统计
        global tx_cnt
        global rx_cnt

        rx_cnt += rx
        tx_cnt += tx
        self.lb3['text'] = '接收：' + str(rx_cnt), '发送：' + str(tx_cnt)

    def savefiles(self):  # 保存日志TXT文本
        try:
            with open('log.txt', 'a') as file:  # a方式打开 文本追加模式
                file.write(self.txt_rx.get(0.0, 'end'))
                messagebox.showinfo('提示', '保存成功')
        except:
            messagebox.showinfo('错误', '保存日志文件失败！')


if __name__ == '__main__':
    print('Star...')
    gui = GUI()
    gui.gettim()  # 开启时钟
    gui.root.mainloop()
    UART.close()  # 结束关闭 避免下次打开错误
    print('End...')
