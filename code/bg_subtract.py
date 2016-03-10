import cv2

# Get a frame from the current video source
def getFrame(cap):
    _, frame = cap.read()
    # frame = cv2.imread('greens.png')
    return frame

FPS = 25.0

videoFilename = 'ShoppingMallShorter.m1v'

# Get a camera input source
cap = cv2.VideoCapture(videoFilename)

# Set up background subtractor
subtractor = cv2.createBackgroundSubtractorMOG2(detectShadows = False)

# Get video output sinks
fourcc1 = cv2.VideoWriter_fourcc(*'DIVX')
out = cv2.VideoWriter('ShoppingMallOutput.avi', fourcc1, FPS, (160,128))

frameNo = 0

while(cap.isOpened()):
    frame = getFrame(cap)
    if frame is None:
        break

    # Blur frame for processing
    frame = cv2.blur(frame, (4,4))

    # Apply background subtraction to get a mask
    fgmask = subtractor.apply(frame)

    masked_frame = cv2.bitwise_and(frame, frame, mask = fgmask)

    cv2.imshow('Subtracted Frame', masked_frame)

    out.write(masked_frame)

    # cv2.imshow('image', cropped_frame)

    k = cv2.waitKey(1) & 0xFF
    
    if k == 27:
        # User hit ESC
        break

    frameNo += 1


# Release everything if job is finished
cap.release()
out.release()
cv2.destroyAllWindows()    