import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as anim
import mpl_toolkits.mplot3d.art3d as art3d
from matplotlib import cm
from time import sleep
import os

"""
GLOBAL VARIABLES
"""
# Coordinates
x0 = -0.125  # Minimum value of the X coordinate.
xn = 2.  # Maximum value of the X coordinate.
y0 = -2  # Minimum value of the Y coordinate.
yn = 2   # Maximum value of the Y coordinate.
z0 = -2  # Minimum value of the Z coordinate.
zn = 2  # Maximum value of the Z coordinate.

# Grid Setup
x = np.linspace(x0 + 0.125, xn, 100)
y = np.linspace(y0, yn, 100)
xx, yy = np.meshgrid(x, y)
zz = xx * 0. + yy * 0.

# Slits Setup
slitsWidth = 0.055  # Width of the slits.
rightSlitCenter = -0.125  # Center of the right slit along the Y axis.
leftSlitCenter = 0.125  # Center of the left slit along the Y axis.

# Wave Setup
k = 2 * np.pi  # Wave number.
w = 1.  # Angular velocity.

# Discretization of the slits.
slitSourcePoints = np.linspace(-slitsWidth / 2, slitsWidth / 2, 10)


def printSlits(axes):
    halfSlitWidth = slitsWidth / 2  # Since we will work from the center of the slit we just need half of the width.

    # Right Slit Wall
    rightWallX = [0, 0, 0, 0]
    rightWallY = [rightSlitCenter + halfSlitWidth, yn, yn, rightSlitCenter + halfSlitWidth]
    rightWallZ = [zn, zn, z0, z0]
    poly = list(zip(rightWallX, rightWallY, rightWallZ))
    axes.add_collection3d(art3d.Poly3DCollection([poly], color='gray'))

    # Center Slit Wall
    centerWallX = [0, 0, 0, 0]
    centerWallY = [leftSlitCenter + halfSlitWidth, rightSlitCenter - halfSlitWidth, rightSlitCenter - halfSlitWidth,
                   leftSlitCenter + halfSlitWidth]
    centerWallZ = [zn, zn, z0, z0]
    poly = list(zip(centerWallX, centerWallY, centerWallZ))
    axes.add_collection3d(art3d.Poly3DCollection([poly], color='gray'))

    # Left Slit Wall
    leftWallX = [0, 0, 0, 0]
    leftWallY = [leftSlitCenter - halfSlitWidth, y0, y0, leftSlitCenter - halfSlitWidth]
    leftWallZ = [zn, zn, z0, z0]
    poly = list(zip(leftWallX, leftWallY, leftWallZ))
    axes.add_collection3d(art3d.Poly3DCollection([poly], color='gray'))


def printAxes(axes):
    axes.set_xlim(x0, xn)
    axes.set_ylim(y0, yn)
    axes.set_zlim(z0, zn)

    axes.set_title('Double Slit Simulation')
    axes.set_xlabel('$x\pi$')
    axes.set_ylabel('$y\pi$')
    axes.set_zlabel('$z$')
    axes.set_box_aspect((1, 1, 0.5))
    axes.grid()


def printAxesText(f, axes):
    axes.text(x0 - 1, y0, zn * 3.3, "Iteration = " + str(f))
    axes.text(x0 - 1, y0, zn * 3., "$k$ = " + str(k))
    axes.text(x0 - 1, y0, zn * 2.7, "Slit Distance = " + str(rightSlitCenter - leftSlitCenter))
    axes.text(x0 - 1, y0, zn * 2.4, "Slit Width = " + str(slitsWidth))


def plotSuperposition(f, axes):
    global zz

    # Clear axes for new iteration.
    axes.cla()

    # Update plot.
    printAxes(axes)
    printAxesText(f, axes)
    printSlits(axes)

    # Reset zz.
    zz = xx * 0. + yy * 0.

    # Superpostion from right slit.
    for point in slitSourcePoints:
        rightSlitDistance = np.sqrt(xx ** 2 + (yy - (point + rightSlitCenter)) ** 2)
        zz = zz + np.sin(k * rightSlitDistance * np.pi - w * f)  # np.pi * x used for adjustment in x axis.

    # Superposition from left slit.
    for point in slitSourcePoints:
        leftSlitDistance = np.sqrt(xx ** 2 + (yy - (point + leftSlitCenter)) ** 2)
        zz = zz + np.sin(k * leftSlitDistance * np.pi - w * f)  # np.pi * x used for adjustment in x axis.

    # "Normalize" zz so it fits in the plot.
    zz = zz / len(slitSourcePoints)
    axes.plot_surface(xx, yy, zz, rstride=1, cstride=1, cmap=cm.Reds, alpha=0.6)


def getUserInput():
    os.system('cls' if os.name == 'nt' else 'clear')

    global slitsWidth, rightSlitCenter, leftSlitCenter

    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    print("[~] USER INPUT                                  [~]")
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    print("[!] Current Simulation Parameters: \n\t- Slit Width = " + str(slitsWidth) + "\n\t- Right Slit Center = "
          + str(rightSlitCenter) + "\n\t- Left Slit Center = " + str(leftSlitCenter))
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

    slitsWidth = float(input("\n- Slit width: "))
    rightSlitCenter = float(input("- Right slit center [0<x<2]: "))
    leftSlitCenter = float(input("- Left slit center [-2<x<0]: "))

    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    os.system('cls' if os.name == 'nt' else 'clear')
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    print("[!] Simulation Parameters updated!: \n\t- Slit Width = " + str(slitsWidth) + "\n\t- Right Slit Center = "
          + str(rightSlitCenter) + "\n\t- Left Slit Center = " + str(leftSlitCenter))
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    sleep(1)
    setup()


def optionsMenu():
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    print("[1] Run                                         [1]")
    print("[2] Customize Parameters                        [2]")
    print("[3] Exit                                        [3]")
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")


def startSimulation():
    fig = plt.figure()
    axes = fig.add_subplot(projection='3d')
    printAxes(axes)
    animation = anim.FuncAnimation(fig, plotSuperposition, fargs=(axes,), interval=100)
    plt.show()
    setup()


def setup():
    os.system('cls' if os.name == 'nt' else 'clear')
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
    print("[~] 3D SIMULATION OF THE DOUBLE SLIT EXPERIMENT [~]")
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n")

    optionsMenu()
    option = int(input("[~] Choose one option [1-3]: "))

    if option == 1:
        print("\nRunning Simulation...")
        startSimulation()
    elif option == 2:
        getUserInput()
    else:
        exit(1)


setup()
