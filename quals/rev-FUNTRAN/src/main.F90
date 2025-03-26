program main
  use types, only: dp
  use integrate, only: trapz
  use arrayops, only: diff, arange, linspace, full
  implicit none
  integer, parameter :: n = 10000
  real(dp), parameter :: prec = 1e-11_dp
  real(dp) :: x(n), y(n)
  real(dp) :: guess, ans

  print *, 'input guess:'
  read *, guess

  x = linspace(0.0_dp, 50.0_dp, size(x))
  y = fn(x) - full(size(y), guess) / (maxval(x) - minval(x))
#if DEBUG
  print *, 'guess: ', guess
  print *, 'ans:   ', trapz(fn(x), x)
#endif
  ! analytical answer for the gaussian
  ! https://www.wolframalpha.com/input?i=sqrt%2869%29
  ! sqrt(69) = 8.3066238629180748...
  ans = trapz(y, x)

  if (abs(ans) < prec) then
    print *, 'yay u got it !! :33 your flag is EPFL{replace_this_by_the_ten_first_decimal_places_of_your_input}'
  else
    print *, 'sowwy uwu'
  end if

contains

  pure elemental function fn(x) result(ret)
    real(dp), intent(in) :: x
    real(dp) :: ret

    ! cool function, but does not converge fast enough
    ! integer, parameter :: A = 5
    ! integer, parameter :: B = 8
    ! ret = A*exp(-x) * (x + 1.0_dp/3.0_dp*x**3) + B/(x**2+1)*2/acos(-1.0_dp)
    ! requires some sort of change of var [0.5,1] -> [0,+infty]
    ! x = linspace(0.5_dp, 1.0_dp - 1.0_dp/real(n, dp), size(x))
    ! x = 100.0_dp * log(x / (1 - x))  ! s(x) = 1/1-exp(-x) => s-1(y) = log(1 / (1 - y))

    ! just a gaussian :)
    ! TODO: maybe to make it easier we could
    !   - add a parameter pi acos(-1.0_dp)
    !   - inline pi
    ret = 2.0_dp / sqrt(acos(-1.0_dp)) * exp(-(x**2)/69.0_dp)
  end function fn

end program main
