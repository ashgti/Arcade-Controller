import serial
import threading
from keyboard import send_key
from time import sleep, time
from copy import copy

repeat_delay = 0.85
repeat_interval = 0.01

# threading repeat key state

lock = threading.Lock()

exiting = False

down_keys = {}

def dispatcher():
    done = exiting
    while not done:
        sleep(0.001)
        with lock:
            done = exiting
            current = time()
            for k, v in down_keys.items():
                if current > v:
                    print 'key is: ', k
                    send_key(k, True, True)
                    down_keys[k] = time() + repeat_interval
                    print 'dispatching'

def send_up(key):
    with lock:
        send_key(key, False)
        del down_keys[key]

def send_down(key, delay):
    with lock:
        send_key(key, True)
        down_keys[key] = delay

def send_keys(keys):
    for x in keys:
        send_down(x)
        send_up(x)

key_map = {
          '6' : 'UpArrow',
          '4' : 'DownArrow',
          '7' : 'LeftArrow',
          '5' : 'RightArrow',
          '9' : 'Control',
          '8' : 'Option'
          }

def main():
    current_state = { 
                    '6' : None,
                    '4' : None,
                    '7' : None,
                    '5' : None,
                    '9' : None,
                    '8' : None
                    }
    controller = serial.Serial('/dev/tty.usbserial-A400fYXu', 57600, timeout=1.0/30.0)
    dispatch_thread = threading.Thread(target=dispatcher)
    dispatch_thread.start()
    try:
        while True:
            was = current_state
            msgs = controller.readline()
            for i in current_state:
                try:
                    if i in msgs and was[i] == None:
                        print 'my delay is: ', time() + repeat_delay
                        send_down(key_map[i], time() + repeat_delay)
                        current_state[i] = True
                    if i not in msgs and was[i] == True:
                        send_up(key_map[i])
                        current_state[i] = None
                except KeyError:
                    pass
    except KeyboardInterrupt:
        print "Finished..."
        exiting = True
        dispatch_thread.join()


if __name__ == '__main__':
    main()
