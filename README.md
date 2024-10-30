# UART串口控制器的设计

## UART协议简介
![UART协议](./doc/uart_protocol.png)

## 仿真结果
![仿真结果](./doc/modelsim_result.png)

## 执行仿真
如果安装了 `make` 工具，可以直接在终端中切换目录到 `script` 下输入 `make` 命令，即可执行仿真。
如果没有 `make` 工具，也可以执行如下代码启动 `Modelsim` 仿真：
```bash
vsim -do run.tcl
```