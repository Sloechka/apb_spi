# Описание контроллера APB SPI

Данный IP блок реализует контроллер периферийного интерфейса SPI,
предназначенный на применение в составе СнК с системной шиной AMBA 3.0
(APB). Контроллер представляет собой SPI master (ведущее) устройство и
может быть использован для подключения различных устройств, таких как
SPI Flash, датчики, экраны и пр.

# Технические характеристики

**Характеристики APB Slave:**

-   Поддержка стандарта APB3
    ([specification](https://developer.arm.com/documentation/ihi0024/c/Introduction/APB-revisions/AMBA-3-APB-Protocol-Specification-v1-0))
-   Параметризуемая шина адреса
-   Размерность шины данных - 32 бит
-   Поддержка pslverr при обращении в недоступные регистры

**Характеристики SPI:**

-   SPI Master
-   4 wire
-   Для тактирования используется APB Clock
-   **TODO**: Программируемые фаза (CPHA) и полярность (CPOL) синхросигнала

# Структурная схема

![scheme]("images/apb_spi.drawio.png")

# Описание интерфейсов блока

## Параметры системы

<table>
    <thead>
        <tr class="header">
            <th>Параметр</th>
            <th>Описание</th>
        </tr>
    </thead>
    <tbody>
        <tr class="odd">
            <td>ADDR_WIDTH</td>
            <td>Ширина шины адреса.</td>
        </tr>
        <tr class="even">
            <td>ALMOST_FULL_VALUE</td>
            <td>Количество записей в FIFO, при котором срабатывает прерывание ALMOST_FULL</td>
        </tr>
    </tbody>
</table>

## Порты контроллера APB

<table>
    <thead>
        <tr class="header">
            <th>Название</th>
            <th>Источник</th>
            <th>Разрядность</th>
            <th>Тип</th>
            <th>Описание</th>
        </tr>
    </thead>
    <tbody>
        <tr class="odd">
            <td>pclk</td>
            <td>Системный синхросигнал</td>
            <td></td>
            <td>in</td>
            <td><strong>Clock.</strong><br />Синхросигнал. Все остальные сигналы APB считываются по переднему фронту этого синхросигнала.</td>
        </tr>
        <tr class="even">
            <td>presetn</td>
            <td>Системный сброс</td>
            <td></td>
            <td>in</td>
            <td><strong>Reset.</strong><br />Асинхронный сигнал сброса с активным "0".</td>
        </tr>
        <tr class="odd">
            <td>paddr</td>
            <td>APB Master</td>
            <td>ADDR_WIDTH</td>
            <td>in</td>
            <td><strong>Address.</strong><br />APB адрес.</td>
        </tr>
        <tr class="even">
            <td>psel</td>
            <td>APB Master</td>
            <td></td>
            <td>in</td>
            <td><strong>Select.</strong><br />Сигнал выбора slave-устройства. Служит для обозначения того, что устройство выбрано и необходима транзакция.</td>
        </tr>
        <tr class="odd">
            <td>penable</td>
            <td>APB Master</td>
            <td></td>
            <td>in</td>
            <td><strong>Enable.</strong><br />Служит для обозначения второй и последующих циклов APB-транзакции.</td>
        </tr>
        <tr class="even">
            <td>pwrite</td>
            <td>APB Master</td>
            <td></td>
            <td>in</td>
            <td><strong>Direction.</strong><br />Выбор направления передачи данных. Высокий уровень - запись, низкий - чтение.</td>
        </tr>
        <tr class="odd">
            <td>pwdata</td>
            <td>APB Master</td>
            <td>32</td>
            <td>in</td>
            <td><strong>Write data.</strong><br />Шина передачи данных Master -&gt; Slave.</td>
        </tr>
        <tr class="even">
            <td>prdata</td>
            <td>APB Slave</td>
            <td>32</td>
            <td>out</td>
            <td><strong>Read data.</strong><br />Шина передачи данных Slave -&gt; Master.</td>
        </tr>
        <tr class="odd">
            <td>pready</td>
            <td>APB Slave</td>
            <td></td>
            <td>out</td>
            <td><strong>Ready.</strong><br />Сигнализирует об окончании передачи данных по шине.</td>
        </tr>
        <tr class="even">
            <td>pslverr</td>
            <td>APB Slave</td>
            <td></td>
            <td>out</td>
            <td><strong>Transfer error.</strong><br />Сигнализирует об ошибке транзакции. Возникает при попытке обращения по невалидному адресу регистра.</td>
        </tr>
    </tbody>
</table>

## Порты SPI

Все шины однобитные.

<table>
    <thead>
        <tr class="header">
            <th>Название</th>
            <th>Источник</th>
            <th>Тип</th>
            <th>Описание</th>
        </tr>
    </thead>
    <tbody>
        <tr class="odd">
            <td>cs</td>
            <td>SPI Master</td>
            <td>out</td>
            <td><strong>Chip select.</strong><br />Сигнал выбора ведомого устройства, используется для инициализация транзакции с перифейриным устройством.</td>
        </tr>
        <tr class="even">
            <td>sck</td>
            <td>SPI Master</td>
            <td>out</td>
            <td><strong>Clock.</strong><br />
Синхросигнал, используется для передачи ведомому устройству.<br />Для тактирования используется APB Clock.</td>
        </tr>
        <tr class="odd">
            <td>mosi</td>
            <td>SPI Master</td>
            <td>out</td>
            <td><strong>Master output, slave input.</strong><br />Выход ведущего, вход ведомого, служит для передачи данных от ведущего устройства ведомому.</td>
        </tr>
        <tr class="even">
            <td>miso</td>
            <td>SPI Slave</td>
            <td>in</td>
            <td><strong>Master input, slave output.</strong><br />Вход ведущего, выход ведомого, служит для передачи данных от ведомого устройства ведущему.</td>
        </tr>
    </tbody>
</table>

## Прочее

<table>
    <thead>
        <tr class="header">
            <th>Название</th>
            <th>Источник</th>
            <th>Тип</th>
            <th>Описание</th>
        </tr>
    </thead>
    <tbody>
        <tr class="odd">
            <td>irq</td>
            <td>Controller</td>
            <td>out</td>
            <td><strong>Interrupt.</strong><br />
            Сигнал прерывания.</td>
        </tr>
    </tbody>
</table>

# Программная модель

<table>
    <tbody>
        <tr class="odd">
            <td colspan=2><strong>Адрес</strong></td>
            <td><strong>Название регистра</strong></td>
            <td><strong>Доступ</strong></td>
            <td><strong>Описание</strong></td>
        </tr>
        <tr class="even">
            <td colspan=2>0x0</td>
            <td>DATA_TX</td>
            <td>w</td>
            <td>Данные для записи в RX FIFO.</td>
        </tr>
        <tr class="odd">
            <td colspan=2>0x4</td>
            <td>CR</td>
            <td>r/w</td>
            <td>Регистр управления блоком (Control register).</td>
        </tr>
        <tr class="even">
            <td><strong>Адрес</strong></td>
            <td><strong>Биты</strong></td>
            <td><strong>Название поля</strong></td>
            <td><strong>Доступ</strong></td>
            <td><strong>Описание</strong></td>
        </tr>
        <tr class="odd">
            <td rowspan=5>0x4</td>
            <td>0</td>
            <td>SPI_EN</td>
            <td>r/w</td>
            <td>0 – контроллер SPI выключен, CS имеет высокий уровень;1 – контроллер включен, CS переключается на низкий (активный) уровень, транзакции будут идти при наличии данных в кольцевой буфер TX FIFO.</td>
        </tr>
        <tr class="even">
            <td>1</td>
            <td>CPHA</td>
            <td>r/w</td>
            <td>Управляет фазой SCK.0 – нормальный режим; данные семплируются по положительному фронту синхросигнала, выставляются – по нисходящему;1 – инверсный режим.</td>
        </tr>
        <tr class="odd">
            <td>2</td>
            <td>CPOL</td>
            <td>r/w</td>
            <td>Управляет полярностью SCK.0 – активный высокий уровень;1 – активный низкий уровень.</td>
        </tr>
        <tr class="even">
            <td>3</td>
            <td>FLUSH_TX</td>
            <td>r/w</td>
            <td>При записи единицы в данное поле происходит очистка буфера TX FIFO. Для повторной очистки необходимо сбросить и записать данный бит еще раз.</td>
        </tr>
        <tr class="odd">
            <td>4</td>
            <td>FLUSH_RX</td>
            <td>r/w</td>
            <td>При записи единицы в данное поле происходит очистка буфера RX FIFO.</td>
        </tr>
        <tr class="even">
            <td colspan=2>0x8</td>
            <td>PRESC</td>
            <td>r/w</td>
            <td>Значение коэффициента делителя частоты синхросигнала.0 – bypass PCLK (от APB); другие значения – частота SCK понижается в 2^c раз (c – значение в регистре).</td>
        </tr>
        <tr class="odd">
            <td colspan=2>0xc</td>
            <td>IRQ_EN</td>
            <td>r/w</td>
            <td>Маска прерываний.</td>
        </tr>
        <tr class="even">
            <td><strong>Адрес</strong></td>
            <td><strong>Биты</strong></td>
            <td><strong>Название поля</strong></td>
            <td><strong>Доступ</strong></td>
            <td><strong>Описание</strong></td>
        </tr>
        <tr class="odd">
            <td rowspan=5>0xc</td>
            <td>0</td>
            <td>EN_TX_EMPTY</td>
            <td>r/w</td>
            <td>Запись единицы включает прерывание по событию tx_empty (буфер TX FIFO пуст).</td>
        </tr>
        <tr class="even">
            <td>1</td>
            <td>EN_TX_FULL</td>
            <td>r/w</td>
            <td>Запись единицы включает прерывание по событию tx_full (буфер TX FIFO `ALMOST_FULL_VALUE записей).</td>
        </tr>
        <tr class="odd">
            <td>2</td>
            <td>EN_RX_EMPTY</td>
            <td>r/w</td>
            <td>Запись единицы включает прерывание по событию rx_empty (буфер RX FIFO пуст).</td>
        </tr>
        <tr class="even">
            <td>3</td>
            <td>EN_RX_FULL</td>
            <td>r/w</td>
            <td>Запись единицы включает прерывание по событию rx_full (буфер RX FIFO `ALMOST_FULL_VALUE записей).</td>
        </tr>
        <tr class="odd">
            <td>4</td>
            <td>EN_TRX_DONE</td>
            <td>r/w</td>
            <td>Запись единицы включает прерывание по событию trx_done (SPI транзакция закончена).</td>
        </tr>
        <tr class="even">
            <td colspan=2>0x10</td>
            <td>IRQ_EN</td>
            <td>r/w</td>
            <td>Регистр, хранящий прерывания. В соответствующие поля записываются единицы при срабатывании соответствующих событий. Для сброса прерывания необходимо записать в соответствующее поле 0.</td>
        </tr>
        <tr class="odd">
            <td><strong>Адрес</strong></td>
            <td><strong>Биты</strong></td>
            <td><strong>Название поля</strong></td>
            <td><strong>Доступ</strong></td>
            <td><strong>Описание</strong></td>
        </tr>
        <tr class="even">
            <td rowspan=5>0x10</td>
            <td>0</td>
            <td>TX_EMPTY</td>
            <td>r/w</td>
            <td>Событие tx_empty (буфер TX FIFO пуст).</td>
        </tr>
        <tr class="odd">
            <td>1</td>
            <td>TX_ALMOST_FULL</td>
            <td>r/w</td>
            <td>Событие tx_almost_full (буфер TX FIFO `ALMOST_FULL_VALUE записей.).</td>
        </tr>
        <tr class="even">
            <td>2</td>
            <td>RX_EMPTY</td>
            <td>r/w</td>
            <td>Событие rx_empty (буфер RX FIFO пуст).</td>
        </tr>
        <tr class="odd">
            <td>3</td>
            <td>RX_ALMOST_FULL</td>
            <td>r/w</td>
            <td>Событие rx_almost_full (буфер RX FIFO `ALMOST_FULL_VALUE записей.).</td>
        </tr>
        <tr class="even">
            <td>4</td>
            <td>TRX_DONE</td>
            <td>r/w</td>
            <td>Событие trx_done (SPI транзакция закончена).</td>
        </tr>
        <tr class="odd">
            <td colspan=2>0x14</td>
            <td>SR</td>
            <td>r</td>
            <td>Статусный регистр (status register).</td>
        </tr>
        <tr class="even">
            <td><strong>Адрес</strong></td>
            <td><strong>Биты</strong></td>
            <td><strong>Название поля</strong></td>
            <td><strong>Доступ</strong></td>
            <td><strong>Описание</strong></td>
        </tr>
        <tr class="odd">
            <td rowspan=5>0x14</td>
            <td>0</td>
            <td>BUSY</td>
            <td>r</td>
            <td>SPI-транзакция в процессе.</td>
        </tr>
        <tr class="even">
            <td>1</td>
            <td>TX_EMPTY</td>
            <td>r</td>
            <td>Буфер TX FIFO пуст.</td>
        </tr>
        <tr class="odd">
            <td>2</td>
            <td>TX_ALMOST_FULL</td>
            <td>r</td>
            <td>Буфер TX FIFO имеет `ALMOST_FULL_VALUE записей.</td>
        </tr>
        <tr class="even">
            <td>3</td>
            <td>RX_EMPTY</td>
            <td>r</td>
            <td>Буфер RX FIFO пуст.</td>
        </tr>
        <tr class="odd">
            <td>4</td>
            <td>RX_ALMOST_FULL</td>
            <td>r</td>
            <td>Буфер RX FIFO имеет `ALMOST_FULL_VALUE записей.</td>
        </tr>
        <tr class="even">
            <td colspan=2>0x18</td>
            <td>DATA_RX</td>
            <td>r</td>
            <td>Данные для считывания из буфера RX FIFO.</td>
        </tr>
    </tbody>
</table>
