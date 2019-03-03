## bochs 使用

### 基本配置
```shell
# 设置内存大小, 32MB
megs: 32

# 设置对应真实机器的BIOS和VGA BIOS
romimage: file=/usr/share/bochs/BIOS-bochs-latest
vgaromimage: file=/usr/share/bochs/VGABIOS-lgpl-latest

# 选择启动盘符
boot: disk

# 设置日志输出文件
log: bochs.out

# 关闭鼠标打开键盘
mouse: enabled=0
keyboard: keymap=/usr/share/bochs/keymaps/x11-pc-us.map

# 硬盘设置
ata0: enabled=1, ioaddr1=0x1f0, ioaddr2=0x3f0, irq=14

```

好了一个基本的bochs配置大概就是这样就行了。如果你想要更为详细的配置,你可以到 `/usr/share/doc/bochs/bochsrc-sample.txt` 中查看其他配置, 里面有好多配置不过也给了一些注释使用。一千多行看着是有点头疼~~hhhH

对了, 这里面配置的的路径有可能和大家的不太一样(不过我感觉大概率是一样的)，也许要自己修改一下了:laughing:

### bximage创建硬盘

其实前面的那个配置还是不够齐全, 对不起~我欺骗了大家。不过令人高兴的是我们只需要再加一行配置就 OK 了

之所以放在这里也是为了排版需要哈哈哈

在前面我们设置了硬盘参数, 其实我们还需要指定是哪个硬盘。在指定之前呢, 我们先来创建好一个虚拟硬盘, 可以利用 `bochs` 提供的 `bximage`命令

```shell
# 下面是参数说明
# -hd 指定硬盘大小
# -mode 指定模式
# -q 静默模式创建
bximage -hd=60M -mode=create -q a.img
```

创建完 `bochs` 还会很良心地提示我们要在我们的配置文件中加上下面这行配置, 现在我们就把它加到我们的配置中去吧！

```
ata0-master: type=disk, path="a.img", mode=flat
```

现在我们可以运行

```shell
bochs -f 指定配置文件
```

这样就可以看到我们的 `bochs` 在运行啦！

### 使用bochs进行调试

使用 `help` 命令可以查看 `bochs` 支持的命令

`help 命令` 可以查看命令如何使用

#### 内存查看

```shell
# 指令格式 xp /nuf <addr>
# n 指定单元个数
# u 指定单元大小
# f 指定输出格式
xp /10bx 0xb8000 #输出0x8b000往后10个字节, 以16进制的方式输出
```

| u        | b     | h     | w     | g     |
| -------- | ----- | ----- | ----- | ----- |
| 单元大小 | 1字节 | 2字节 | 4字节 | 8字节 |

| f        | x      | d     | u        | o      | t      | c    |
| -------- | ------ | ----- | -------- | ------ | ------ | ---- |
| 输出格式 | 16进制 | 8进制 | 无符号数 | 十进制 | 二进制 | 字符 |

#### 查看指定内存中的指令

``` shell
# 指令格式 u [/count] <start> <end>
u /10 # 输出当前往后的十个指令
u /10 0x7c00 # 输出0x7c00往后的十个指令
u /100 0x7c00 0x7c10 # 输出0x7c00到0x7c10之间的100个指令, 如果没有这么多就有多少输出多少
```

#### 控制执行

```shell
# 向下一直运行下去,直到遇到断点
c | cont | continue
# 执行 count 条命令, 不指定的话默认为1, 若遇到函数调用会跳进函数中执行
s | step [count]
# 执行 1 条命令, 若遇到函数调用会把整个函数当成一条指令
p | n | next 
```

#### 断点管理

```shell
# 为物理位置添加断点
pb | pbreak | b | break [addr]
```



