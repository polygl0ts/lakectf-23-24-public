module integrate
  use types, only: dp
  use arrayops, only: midpoints, diff, ones
  implicit none
  private
  
  public :: trapz
  
contains

  ! WARNING : for some reason with this syntax f2py does not automatically find real(kind=8), but finds real (which has default kind=4)
  ! real(dp) function trapz(y, x) result(r)
  function trapz(y, x) result(r)
    real(dp) :: r
    real(dp), intent(in) :: y(:)
    real(dp), intent(in), optional :: x(size(y))
    real(dp) :: s(size(y)-1)
    
    s = midpoints(y)
    if ( present(x) ) s = s * diff(x)
    r = sum(s)
  end function trapz
end module integrate