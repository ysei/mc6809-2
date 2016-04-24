#/ <reference path="references.ts" />
mc6809 = undefined
((mc6809) ->
  
  # Instruction timing for single-byte opcodes 
  
  # Instruction timing for the two-byte opcodes 
  
  # Pending interrupt bits 
  makeSignedByte = (x) ->
    x << 24 >> 24
  makeSignedWord = (x) ->
    x << 16 >> 16
  SET_V8 = (a, b, r) ->
    
    # TODO: might need to mask & 0xff each param.
    ((a ^ b ^ r ^ (r >> 1)) & 0x80) >> 6
  SET_V16 = (a, b, r) ->
    
    # TODO: might need to mask & 0xffff each param.
    ((a ^ b ^ r ^ (r >> 1)) & 0x8000) >> 14
  F = undefined
  ((F) ->
    F[F["CARRY"] = 1] = "CARRY"
    F[F["OVERFLOW"] = 2] = "OVERFLOW"
    F[F["ZERO"] = 4] = "ZERO"
    F[F["NEGATIVE"] = 8] = "NEGATIVE"
    F[F["IRQMASK"] = 16] = "IRQMASK"
    F[F["HALFCARRY"] = 32] = "HALFCARRY"
    F[F["FIRQMASK"] = 64] = "FIRQMASK"
    F[F["ENTIRE"] = 128] = "ENTIRE"
  ) F or (F = {})
  c6809Cycles = [ 6, 0, 0, 6, 6, 0, 6, 6, 6, 6, 6, 0, 6, 6, 3, 6, 0, 0, 2, 4, 0, 0, 5, 9, 0, 2, 3, 0, 3, 2, 8, 6, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 5, 3, 6, 9, 11, 0, 19, 2, 0, 0, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 0, 2, 2, 0, 0, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 0, 2, 6, 0, 0, 6, 6, 0, 6, 6, 6, 6, 6, 0, 6, 6, 3, 6, 7, 0, 0, 7, 7, 0, 7, 7, 7, 7, 7, 0, 7, 7, 4, 7, 2, 2, 2, 4, 2, 2, 2, 0, 2, 2, 2, 2, 4, 7, 3, 0, 4, 4, 4, 6, 4, 4, 4, 4, 4, 4, 4, 4, 6, 7, 5, 5, 4, 4, 4, 6, 4, 4, 4, 4, 4, 4, 4, 4, 6, 7, 5, 5, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 7, 8, 6, 6, 2, 2, 2, 4, 2, 2, 2, 0, 2, 2, 2, 2, 3, 0, 3, 0, 4, 4, 4, 6, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 4, 4, 4, 6, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 7, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6, 6 ]
  c6809Cycles2 = [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 4, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 6, 6, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 6, 6, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7 ]
  MEM_ROM = 0x00000
  MEM_RAM = 0x10000
  MEM_FLAGS = 0x20000
  INT_NMI = 1
  INT_FIRQ = 2
  INT_IRQ = 4
  MemBlock = (->
    MemBlock = (start, len, read, write) ->
      @start = start
      @len = len
      @read = read
      @write = write
    MemBlock
  )()
  mc6809.MemBlock = MemBlock
  ROM = (->
    ROM = (name, mem) ->
      @name = name
      @mem = mem
    ROM
  )()
  mc6809.ROM = ROM
  Emulator = (->
    Emulator = ->
      _this = this
      @getRegD = ->
        0xffff & (_this.regA << 8 | _this.regB & 0xff)

      @setRegD = (value) ->
        _this.regB = value & 0xff
        _this.regA = (value >> 8) & 0xff

      @pcCount = 0
      @memHandler = []
      @counts = {}
      @inorder = []
      @debug = false
      @hex = (v, width) ->
        s = v.toString(16)
        width = 2  unless width
        s = "0" + s  while s.length < width
        s

      @stateToString = ->
        "pc:" + _this.hex(_this.regPC, 4) + " s:" + _this.hex(_this.regS, 4) + " u:" + _this.hex(_this.regU, 4) + " x:" + _this.hex(_this.regX, 4) + " y:" + _this.hex(_this.regY, 4) + " a:" + _this.hex(_this.regA, 2) + " b:" + _this.hex(_this.regB, 2) + " d:" + _this.hex(_this.getRegD(), 4) + " dp:" + _this.hex(_this.regDP, 2) + " cc:" + _this.flagsToString()

      @nextOp = ->
        pc = _this.regPC
        nextop = _this.M6809ReadByte(pc)
        mn = _this.mnemonics
        if nextop is 0x10
          mn = _this.mnemonics10
          nextop = _this.M6809ReadByte(++pc)
        else if nextop is 0x11
          mn = _this.mnemonics11
          nextop = _this.M6809ReadByte(++pc)
        mn[nextop]

      @state = ->
        pc = _this.regPC
        nextop = _this.M6809ReadByte(pc)
        mn = _this.mnemonics
        if nextop is 0x10
          mn = _this.mnemonics10
          nextop = _this.M6809ReadByte(++pc)
        else if nextop is 0x11
          mn = _this.mnemonics11
          nextop = _this.M6809ReadByte(++pc)
        ret = _this.hex(pc, 4) + " " + mn[nextop] + " " + _this.hex(_this.readByteROM(pc + 1), 2) + " " + _this.hex(_this.readByteROM(pc + 2), 2) + " "
        ret += " s:" + _this.hex(_this.regS, 4) + " u:" + _this.hex(_this.regU, 4) + " x:" + _this.hex(_this.regX, 4) + " y:" + _this.hex(_this.regY, 4) + " a:" + _this.hex(_this.regA, 2) + " b:" + _this.hex(_this.regB, 2) + " d:" + _this.hex(_this.getRegD(), 4) + " dp:" + _this.hex(_this.regDP, 2) + " cc:" + _this.flagsToString() + "  [" + _this.pcCount + "]"
        ret

      @flagsToString = ->
        ((if (_this.regCC & 8) then "N" else "-")) + ((if (_this.regCC & 4) then "Z" else "-")) + ((if (_this.regCC & 1) then "C" else "-")) + ((if (_this.regCC & 16) then "I" else "-")) + ((if (_this.regCC & 32) then "H" else "-")) + ((if (_this.regCC & 2) then "V" else "-")) + ((if (_this.regCC & 64) then "C" else "-")) + ((if (_this.regCC & 128) then "E" else "-")) # NEGATIVE 
# ZERO 
# CARRY 
# IRQMASK 
# HALFCARRY 
# OVERFLOW 
# FIRQMASK 
# ENTIRE

      @execute = (iClocks, interruptRequest, breakpoint) ->
        _this.iClocks = iClocks
        console.log "breakpoint set: " + breakpoint.toString(16)  if breakpoint
        while _this.iClocks > 0
          if breakpoint and _this.regPC is breakpoint
            console.log "hit breakpoint at " + breakpoint.toString(16)
            _this.halt()
            break
          interruptRequest = _this.handleIRQ(interruptRequest)
          mn = _this.nextOp()
          if _this.counts.hasOwnProperty(mn)
            _this.counts[mn]++
          else
            _this.inorder.push mn
            _this.counts[mn] = 1
          ucOpcode = _this.nextPCByte()
          _this.iClocks -= c6809Cycles[ucOpcode] # Subtract execution time
          console.log (_this.regPC - 1).toString(16) + ": " + _this.mnemonics[ucOpcode]  if _this.debug
          instruction = _this.instructions[ucOpcode]
          unless instruction?
            console.log "*** illegal opcode: " + ucOpcode.toString(16) + " at " + (_this.regPC - 1).toString(16)
            _this.iClocks = 0
            _this.halt()
          else
            instruction()

      @readByteROM = (addr) ->
        ucByte = _this.mem[MEM_ROM + addr]
        
        # console.log("Read ROM: " + addr.toString(16) + " -> " + ucByte.toString(16));
        ucByte

      @reset = ->
        _this.regX = 0
        _this.regY = 0
        _this.regU = 0
        _this.regS = _this.stackAddress
        _this.regA = 0
        _this.regB = 0
        _this.regDP = 0
        _this.regCC = 64 | 16 # FIRQMASK 
# IRQMASK
        _this.regPC = 0
        _this._goto (_this.readByteROM(0xfffe) << 8) | _this.readByteROM(0xffff)

      @setStackAddress = (addr) ->
        _this.stackAddress = addr

      @loadMemory = (bytes, addr) ->
        _this.mem.set bytes, addr

      @setMemoryMap = (map) ->
        $.each map, (index, block) ->
          i = 0

          while i < block.len
            _this.mem[MEM_FLAGS + block.start + i] = index
            i++
          _this.memHandler.push block  if index > 1


      @halted = false
      @halt = ->
        _this.halted = true
        _this.iClocks = 0
        console.log "halted."

      @nextPCByte = ->
        _this.pcCount++
        _this.M6809ReadByte _this.regPC++

      @nextPCWord = ->
        word = _this.M6809ReadWord(_this.regPC)
        _this.regPC += 2
        _this.pcCount += 2
        word

      @M6809ReadByte = (addr) ->
        c = _this.mem[addr + MEM_FLAGS]
        switch c
          when 0
            ucByte = _this.mem[addr + MEM_RAM]
            
            # console.log("Read RAM: " + addr.toString(16) + " -> " + ucByte.toString(16));
            ucByte
          when 1
            ucByte = _this.mem[addr + MEM_ROM]
            
            #  console.log("Read ROM: " + addr.toString(16) + " -> " + ucByte.toString(16));
            ucByte
          else
            handler = _this.memHandler[c - 2]
            if handler is `undefined`
              console.log "need read handler at " + (c - 2)
              return 0
            handler.read addr

      @M6809WriteByte = (addr, ucByte) ->
        c = _this.mem[addr + MEM_FLAGS]
        switch c
          when 0
            
            # console.log("Write RAM: " + addr.toString(16) + " = " + (ucByte & 0xff).toString(16));
            _this.mem[addr + MEM_RAM] = ucByte & 0xff
          when 1
            console.log "******** Write ROM: from PC: " + _this.regPC.toString(16) + "   " + addr.toString(16) + " = " + (ucByte & 0xff).toString(16)
            _this.mem[addr + MEM_ROM] = ucByte & 0xff # write it to ROM anyway...
          else
            handler = _this.memHandler[c - 2]
            if handler is `undefined`
              console.log "need write handler at " + (c - 2)
            else
              handler.write addr, ucByte & 0xff

      @M6809ReadWord = (addr) ->
        hi = _this.M6809ReadByte(addr)
        lo = _this.M6809ReadByte(addr + 1)
        hi << 8 | lo

      @M6809WriteWord = (addr, usWord) ->
        _this.M6809WriteByte addr, usWord >> 8
        _this.M6809WriteByte addr + 1, usWord

      @pushByte = (ucByte, user) ->
        addr = (if user then --_this.regU else --_this.regS)
        _this.M6809WriteByte addr, ucByte

      @M6809PUSHBU = (ucByte) ->
        _this.pushByte ucByte, true

      @M6809PUSHB = (ucByte) ->
        _this.pushByte ucByte, false

      @M6809PUSHW = (usWord) ->
        
        # push lo byte first.
        _this.M6809PUSHB usWord
        _this.M6809PUSHB usWord >> 8

      @M6809PUSHWU = (usWord) ->
        
        # push lo byte first.
        _this.M6809PUSHBU usWord
        _this.M6809PUSHBU usWord >> 8

      @pullByte = (user) ->
        addr = (if user then _this.regU else _this.regS)
        val = _this.M6809ReadByte(addr)
        if user
          ++_this.regU
        else
          ++_this.regS
        val

      @M6809PULLB = ->
        _this.pullByte false

      @M6809PULLBU = ->
        _this.pullByte true

      @M6809PULLW = ->
        hi = _this.M6809PULLB()
        lo = _this.M6809PULLB()
        hi << 8 | lo

      @M6809PULLWU = ->
        hi = _this.M6809PULLBU()
        lo = _this.M6809PULLBU()
        hi << 8 | lo

      @M6809PostByte = ->
        pReg = undefined
        usAddr = undefined
        sTemp = undefined
        ucPostByte = _this.nextPCByte()
        switch ucPostByte & 0x60
          when 0
            pReg = "X"
          when 0x20
            pReg = "Y"
          when 0x40
            pReg = "U"
          when 0x60
            pReg = "S"
        pReg = "reg" + pReg
        if (ucPostByte & 0x80) is 0
          
          # Just a 5 bit signed offset + register 
          sByte = ucPostByte & 0x1f
          sByte -= 32  if sByte > 15
          _this.iClocks -= 1
          return _this[pReg] + sByte
        switch ucPostByte & 0xf
          when 0
            usAddr = _this[pReg]
            _this[pReg] += 1
            _this.iClocks -= 2
          when 1
            usAddr = _this[pReg]
            _this[pReg] += 2
            _this.iClocks -= 3
          when 2
            _this[pReg] -= 1
            usAddr = _this[pReg]
            _this.iClocks -= 2
          when 3
            _this[pReg] -= 2
            usAddr = _this[pReg]
            _this.iClocks -= 3
          when 4
            usAddr = _this[pReg]
          when 5
            usAddr = _this[pReg] + makeSignedByte(_this.regB)
            _this.iClocks -= 1
          when 6
            usAddr = _this[pReg] + makeSignedByte(_this.regA)
            _this.iClocks -= 1
          when 7
            console.log "illegal postbyte pattern 7 at " + (_this.regPC - 1).toString(16)
            _this.halt()
            usAddr = 0
          when 8
            usAddr = _this[pReg] + makeSignedByte(_this.nextPCByte())
            _this.iClocks -= 1
          when 9
            usAddr = _this[pReg] + makeSignedWord(_this.nextPCWord())
            _this.iClocks -= 4
          when 0xA
            console.log "illegal postbyte pattern 0xA" + (_this.regPC - 1).toString(16)
            _this.halt()
            usAddr = 0
          when 0xB
            _this.iClocks -= 4
            usAddr = _this[pReg] + _this.getRegD()
          when 0xC
            sTemp = makeSignedByte(_this.nextPCByte())
            usAddr = _this.regPC + sTemp
            _this.iClocks -= 1
          when 0xD
            sTemp = makeSignedWord(_this.nextPCWord())
            usAddr = _this.regPC + sTemp
            _this.iClocks -= 5
          when 0xE
            console.log "illegal postbyte pattern 0xE" + (_this.regPC - 1).toString(16)
            _this.halt()
            usAddr = 0
          when 0xF
            _this.iClocks -= 5
            usAddr = _this.nextPCWord()
        if ucPostByte & 0x10
          usAddr = _this.M6809ReadWord(usAddr & 0xffff)
          _this.iClocks -= 3
        usAddr & 0xffff

      @M6809PSHS = (ucTemp) ->
        i = 0
        if ucTemp & 0x80
          _this.M6809PUSHW _this.regPC
          i += 2
        if ucTemp & 0x40
          _this.M6809PUSHW _this.regU
          i += 2
        if ucTemp & 0x20
          _this.M6809PUSHW _this.regY
          i += 2
        if ucTemp & 0x10
          _this.M6809PUSHW _this.regX
          i += 2
        if ucTemp & 0x8
          _this.M6809PUSHB _this.regDP
          i++
        if ucTemp & 0x4
          _this.M6809PUSHB _this.regB
          i++
        if ucTemp & 0x2
          _this.M6809PUSHB _this.regA
          i++
        if ucTemp & 0x1
          _this.M6809PUSHB _this.regCC
          i++
        _this.iClocks -= i # Add extra clock cycles (1 per byte)

      @M6809PSHU = (ucTemp) ->
        i = 0
        if ucTemp & 0x80
          _this.M6809PUSHWU _this.regPC
          i += 2
        if ucTemp & 0x40
          _this.M6809PUSHWU _this.regU
          i += 2
        if ucTemp & 0x20
          _this.M6809PUSHWU _this.regY
          i += 2
        if ucTemp & 0x10
          _this.M6809PUSHWU _this.regX
          i += 2
        if ucTemp & 0x8
          _this.M6809PUSHBU _this.regDP
          i++
        if ucTemp & 0x4
          _this.M6809PUSHBU _this.regB
          i++
        if ucTemp & 0x2
          _this.M6809PUSHBU _this.regA
          i++
        if ucTemp & 0x1
          _this.M6809PUSHBU _this.regCC
          i++
        _this.iClocks -= i # Add extra clock cycles (1 per byte)

      @M6809PULS = (ucTemp) ->
        i = 0
        if ucTemp & 0x1
          _this.regCC = _this.M6809PULLB()
          i++
        if ucTemp & 0x2
          _this.regA = _this.M6809PULLB()
          i++
        if ucTemp & 0x4
          _this.regB = _this.M6809PULLB()
          i++
        if ucTemp & 0x8
          _this.regDP = _this.M6809PULLB()
          i++
        if ucTemp & 0x10
          _this.regX = _this.M6809PULLW()
          i += 2
        if ucTemp & 0x20
          _this.regY = _this.M6809PULLW()
          i += 2
        if ucTemp & 0x40
          _this.regU = _this.M6809PULLW()
          i += 2
        if ucTemp & 0x80
          _this._goto _this.M6809PULLW()
          i += 2
        _this.iClocks -= i # Add extra clock cycles (1 per byte)

      @M6809PULU = (ucTemp) ->
        i = 0
        if ucTemp & 0x1
          _this.regCC = _this.M6809PULLBU()
          i++
        if ucTemp & 0x2
          _this.regA = _this.M6809PULLBU()
          i++
        if ucTemp & 0x4
          _this.regB = _this.M6809PULLBU()
          i++
        if ucTemp & 0x8
          _this.regDP = _this.M6809PULLBU()
          i++
        if ucTemp & 0x10
          _this.regX = _this.M6809PULLWU()
          i += 2
        if ucTemp & 0x20
          _this.regY = _this.M6809PULLWU()
          i += 2
        if ucTemp & 0x40
          _this.regU = _this.M6809PULLWU()
          i += 2
        if ucTemp & 0x80
          _this._goto _this.M6809PULLWU()
          i += 2
        _this.iClocks -= i # Add extra clock cycles (1 per byte)

      @handleIRQ = (interruptRequest) ->
        
        # NMI is highest priority 
        if interruptRequest & INT_NMI
          console.log "taking NMI!!!!"
          _this.M6809PUSHW _this.regPC
          _this.M6809PUSHW _this.regU
          _this.M6809PUSHW _this.regY
          _this.M6809PUSHW _this.regX
          _this.M6809PUSHB _this.regDP
          _this.M6809PUSHB _this.regB
          _this.M6809PUSHB _this.regA
          _this.regCC |= 0x80 # Set bit indicating machine state on stack
          _this.M6809PUSHB _this.regCC
          _this.regCC |= 64 | 16 # FIRQMASK 
# IRQMASK 
# Mask interrupts during service routine
          _this.iClocks -= 19
          _this._goto _this.M6809ReadWord(0xfffc)
          interruptRequest &= ~INT_NMI # clear this bit
          console.log _this.state()
          return interruptRequest
        
        # Fast IRQ is next priority 
        if interruptRequest & INT_FIRQ and (_this.regCC & 64) is 0 # FIRQMASK
          console.log "taking FIRQ!!!!"
          _this.M6809PUSHW _this.regPC
          _this.regCC &= 0x7f # Clear bit indicating machine state on stack
          _this.M6809PUSHB _this.regCC
          interruptRequest &= ~INT_FIRQ # clear this bit
          _this.regCC |= 64 | 16 # FIRQMASK 
# IRQMASK 
# Mask interrupts during service routine
          _this.iClocks -= 10
          _this._goto _this.M6809ReadWord(0xfff6)
          console.log _this.state()
          return interruptRequest
        
        # IRQ is lowest priority 
        if interruptRequest & INT_IRQ and (_this.regCC & 16) is 0 # IRQMASK
          console.log "taking IRQ!!!!"
          _this.M6809PUSHW _this.regPC
          _this.M6809PUSHW _this.regU
          _this.M6809PUSHW _this.regY
          _this.M6809PUSHW _this.regX
          _this.M6809PUSHB _this.regDP
          _this.M6809PUSHB _this.regB
          _this.M6809PUSHB _this.regA
          _this.regCC |= 0x80 # Set bit indicating machine state on stack
          _this.M6809PUSHB _this.regCC
          _this.regCC |= 16 # IRQMASK 
# Mask interrupts during service routine
          _this._goto _this.M6809ReadWord(0xfff8)
          interruptRequest &= ~INT_IRQ # clear this bit
          _this.iClocks -= 19
          console.log _this.state()
          return interruptRequest
        interruptRequest

      @toggleDebug = ->
        _this.debug = not _this.debug
        console.log "debug " + _this.debug

      @_goto = (usAddr) ->
        if usAddr is 0xFFB3
          console.log "PC from " + _this.regPC.toString(16) + " -> " + usAddr.toString(16)
          console.log "off screen??? " + _this.getRegD().toString(16)  if _this.getRegD() > 0x9800
        _this.regPC = usAddr

      @_flagnz = (val) ->
        if (val & 0xff) is 0
          _this.regCC |= 4 # ZERO
        else _this.regCC |= 8  if val & 0x80 # NEGATIVE

      @_flagnz16 = (val) ->
        if (val & 0xffff) is 0
          _this.regCC |= 4 # ZERO
        else _this.regCC |= 8  if val & 0x8000 # NEGATIVE

      @_neg = (val) ->
        _this.regCC &= ~(1 | 4 | 2 | 8) # CARRY 
# ZERO 
# OVERFLOW 
# NEGATIVE
        _this.regCC |= 2  if val is 0x80 # OVERFLOW
        val = ~val + 1
        val &= 0xff
        _this._flagnz val
        # NEGATIVE 
        _this.regCC |= 1  if _this.regCC & 8 # CARRY
        val

      @_com = (val) ->
        _this.regCC &= ~(4 | 2 | 8) # ZERO 
# OVERFLOW 
# NEGATIVE
        _this.regCC |= 1 # CARRY
        val = ~val
        val &= 0xff
        _this._flagnz val
        val

      @_lsr = (val) ->
        _this.regCC &= ~(4 | 1 | 8) # ZERO 
# CARRY 
# NEGATIVE
        _this.regCC |= 1  if val & 1 # CARRY
        val >>= 1
        val &= 0xff
        _this.regCC |= 4  if val is 0 # ZERO
        val

      @_ror = (val) ->
        oldc = _this.regCC & 1 # CARRY
        _this.regCC &= ~(4 | 1 | 8) # ZERO 
# CARRY 
# NEGATIVE
        _this.regCC |= 1  if val & 1 # CARRY
        val = val >> 1 | oldc << 7
        val &= 0xff
        _this._flagnz val
        val

      @_asr = (val) ->
        _this.regCC &= ~(4 | 1 | 8) # ZERO 
# CARRY 
# NEGATIVE
        _this.regCC |= 1  if val & 1 # CARRY
        val = val & 0x80 | val >> 1
        val &= 0xff
        _this._flagnz val
        val

      @_asl = (val) ->
        oldval = val
        _this.regCC &= ~(4 | 1 | 2 | 8) # ZERO 
# CARRY 
# OVERFLOW 
# NEGATIVE
        _this.regCC |= 1  if val & 0x80 # CARRY
        val <<= 1
        val &= 0xff
        _this._flagnz val
        _this.regCC |= 2  if (oldval ^ val) & 0x80 # OVERFLOW
        val

      @_rol = (val) ->
        oldval = val
        oldc = _this.regCC & 1 # CARRY
        _this.regCC &= ~(4 | 1 | 2 | 8) # ZERO 
# CARRY 
# OVERFLOW 
# NEGATIVE
        _this.regCC |= 1  if val & 0x80 # CARRY
        val = val << 1 | oldc
        val &= 0xff
        _this._flagnz val
        _this.regCC |= 2  if (oldval ^ val) & 0x80 # OVERFLOW
        val

      @_dec = (val) ->
        val--
        val &= 0xff
        _this.regCC &= ~(4 | 2 | 8) # ZERO 
# OVERFLOW 
# NEGATIVE
        _this._flagnz val
        _this.regCC |= 2  if val is 0x7f or val is 0xff # OVERFLOW
        val

      @_inc = (val) ->
        val++
        val &= 0xff
        _this.regCC &= ~(4 | 2 | 8) # ZERO 
# OVERFLOW 
# NEGATIVE
        _this._flagnz val
        _this.regCC |= 2  if val is 0x80 or val is 0 # OVERFLOW
        val

      @_tst = (val) ->
        _this.regCC &= ~(4 | 2 | 8) # ZERO 
# OVERFLOW 
# NEGATIVE
        _this._flagnz val
        val

      @_clr = (addr) ->
        _this.M6809WriteByte addr, 0
        
        # clear N,V,C, set Z 
        _this.regCC &= ~(1 | 2 | 8) # CARRY 
# OVERFLOW 
# NEGATIVE
        _this.regCC |= 4 # ZERO

      @_or = (ucByte1, ucByte2) ->
        _this.regCC &= ~(4 | 2 | 8) # ZERO 
# OVERFLOW 
# NEGATIVE
        ucTemp = ucByte1 | ucByte2
        _this._flagnz ucTemp
        ucTemp

      @_eor = (ucByte1, ucByte2) ->
        _this.regCC &= ~(4 | 2 | 8) # ZERO 
# OVERFLOW 
# NEGATIVE
        ucTemp = ucByte1 ^ ucByte2
        _this._flagnz ucTemp
        ucTemp

      @_and = (ucByte1, ucByte2) ->
        _this.regCC &= ~(4 | 2 | 8) # ZERO 
# OVERFLOW 
# NEGATIVE
        ucTemp = ucByte1 & ucByte2
        _this._flagnz ucTemp
        ucTemp

      @_cmp = (ucByte1, ucByte2) ->
        sTemp = (ucByte1 & 0xff) - (ucByte2 & 0xff)
        _this.regCC &= ~(4 | 1 | 2 | 8) # ZERO 
# CARRY 
# OVERFLOW 
# NEGATIVE
        _this._flagnz sTemp
        _this.regCC |= 1  if sTemp & 0x100 # CARRY
        _this.regCC |= SET_V8(ucByte1, ucByte2, sTemp)

      @_setcc16 = (usWord1, usWord2, lTemp) ->
        _this.regCC &= ~(4 | 1 | 2 | 8) # ZERO 
# CARRY 
# OVERFLOW 
# NEGATIVE
        _this._flagnz16 lTemp
        _this.regCC |= 1  if lTemp & 0x10000 # CARRY
        _this.regCC |= SET_V16(usWord1 & 0xffff, usWord2 & 0xffff, lTemp & 0x1ffff)

      @_cmp16 = (usWord1, usWord2) ->
        lTemp = (usWord1 & 0xffff) - (usWord2 & 0xffff)
        _this._setcc16 usWord1, usWord2, lTemp

      @_sub = (ucByte1, ucByte2) ->
        sTemp = (ucByte1 & 0xff) - (ucByte2 & 0xff)
        _this.regCC &= ~(4 | 1 | 2 | 8) # ZERO 
# CARRY 
# OVERFLOW 
# NEGATIVE
        _this._flagnz sTemp
        _this.regCC |= 1  if sTemp & 0x100 # CARRY
        _this.regCC |= SET_V8(ucByte1, ucByte2, sTemp)
        sTemp & 0xff

      @_sub16 = (usWord1, usWord2) ->
        lTemp = (usWord1 & 0xffff) - (usWord2 & 0xffff)
        _this._setcc16 usWord1, usWord2, lTemp
        lTemp & 0xffff

      @_sbc = (ucByte1, ucByte2) ->
        sTemp = (ucByte1 & 0xff) - (ucByte2 & 0xff) - (_this.regCC & 1)
        _this.regCC &= ~(4 | 1 | 2 | 8) # ZERO 
# CARRY 
# OVERFLOW 
# NEGATIVE
        _this._flagnz sTemp
        _this.regCC |= 1  if sTemp & 0x100 # CARRY
        _this.regCC |= SET_V8(ucByte1, ucByte2, sTemp)
        sTemp & 0xff

      @_add = (ucByte1, ucByte2) ->
        sTemp = (ucByte1 & 0xff) + (ucByte2 & 0xff)
        _this.regCC &= ~(32 | 4 | 1 | 2 | 8) # HALFCARRY 
# ZERO 
# CARRY 
# OVERFLOW 
# NEGATIVE
        _this._flagnz sTemp
        _this.regCC |= 1  if sTemp & 0x100 # CARRY
        _this.regCC |= SET_V8(ucByte1, ucByte2, sTemp)
        _this.regCC |= 32  if (sTemp ^ ucByte1 ^ ucByte2) & 0x10 # HALFCARRY
        sTemp & 0xff

      @_add16 = (usWord1, usWord2) ->
        lTemp = (usWord1 & 0xffff) + (usWord2 & 0xffff)
        _this._setcc16 usWord1, usWord2, lTemp
        lTemp & 0xffff

      @_adc = (ucByte1, ucByte2) ->
        sTemp = (ucByte1 & 0xff) + (ucByte2 & 0xff) + (_this.regCC & 1)
        _this.regCC &= ~(32 | 4 | 1 | 2 | 8) # HALFCARRY 
# ZERO 
# CARRY 
# OVERFLOW 
# NEGATIVE
        _this._flagnz sTemp
        _this.regCC |= 1  if sTemp & 0x100 # CARRY
        _this.regCC |= SET_V8(ucByte1, ucByte2, sTemp)
        _this.regCC |= 32  if (sTemp ^ ucByte1 ^ ucByte2) & 0x10 # HALFCARRY
        sTemp & 0xff

      @dpAddr = ->
        (_this.regDP << 8) + _this.nextPCByte()

      @dpOp = (func) ->
        addr = _this.dpAddr()
        val = _this.M6809ReadByte(addr)
        _this.M6809WriteByte addr, func(val)

      
      # direct page addressing 
      @neg = ->
        _this.dpOp _this._neg

      @com = ->
        _this.dpOp _this._com

      @lsr = ->
        _this.dpOp _this._lsr

      @ror = ->
        _this.dpOp _this._ror

      @asr = ->
        _this.dpOp _this._asr

      @asl = ->
        _this.dpOp _this._asl

      @rol = ->
        _this.dpOp _this._rol

      @dec = ->
        _this.dpOp _this._dec

      @inc = ->
        _this.dpOp _this._inc

      @tst = ->
        _this.dpOp _this._tst

      @jmp = ->
        _this._goto _this.dpAddr()

      @clr = ->
        _this._clr _this.dpAddr()

      
      # P10  extended Op codes 
      @lbrn = ->
        _this.regPC += 2

      @lbhi = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        unless _this.regCC & (1 | 4) # CARRY 
# ZERO
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbls = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        if _this.regCC & (1 | 4) # CARRY 
# ZERO
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbcc = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        unless _this.regCC & 1 # CARRY
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbcs = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        if _this.regCC & 1 # CARRY
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbne = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        unless _this.regCC & 4 # ZERO
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbeq = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        if _this.regCC & 4 # ZERO
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbvc = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        unless _this.regCC & 2 # OVERFLOW
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbvs = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        if _this.regCC & 2 # OVERFLOW
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbpl = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        unless _this.regCC & 8 # NEGATIVE
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbmi = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        if _this.regCC & 8 # NEGATIVE
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbge = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        unless (_this.regCC & 8) ^ (_this.regCC & 2) << 2 # NEGATIVE 
# OVERFLOW
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lblt = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        if (_this.regCC & 8) ^ (_this.regCC & 2) << 2 # NEGATIVE 
# OVERFLOW
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lbgt = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        unless (_this.regCC & 8) ^ (_this.regCC & 2) << 2 or _this.regCC & 4 # NEGATIVE 
# OVERFLOW 
# ZERO
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @lble = ->
        sTemp = makeSignedWord(_this.nextPCWord())
        if (_this.regCC & 8) ^ (_this.regCC & 2) << 2 or _this.regCC & 4 # NEGATIVE 
# OVERFLOW 
# ZERO
          _this.iClocks -= 1 # Extra clock if branch taken
          _this.regPC += sTemp

      @swi2 = ->
        _this.regCC |= 0x80 # Entire machine state stacked
        _this.M6809PUSHW _this.regPC
        _this.M6809PUSHW _this.regU
        _this.M6809PUSHW _this.regY
        _this.M6809PUSHW _this.regX
        _this.M6809PUSHB _this.regDP
        _this.M6809PUSHB _this.regA
        _this.M6809PUSHB _this.regB
        _this.M6809PUSHB _this.regCC
        _this._goto _this.M6809ReadWord(0xfff4)

      @cmpd = ->
        usTemp = _this.nextPCWord()
        _this._cmp16 _this.getRegD(), usTemp

      @cmpy = ->
        usTemp = _this.nextPCWord()
        _this._cmp16 _this.regY, usTemp

      @ldy = ->
        _this.regY = _this.nextPCWord()
        _this._flagnz16 _this.regY
        _this.regCC &= ~2 # OVERFLOW

      @cmpdd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.getRegD(), usTemp

      @cmpyd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regY, usTemp

      @ldyd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.regY = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regY
        _this.regCC &= ~2 # OVERFLOW

      @sty = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.M6809WriteWord usAddr, _this.regY
        _this._flagnz16 _this.regY
        _this.regCC &= ~2 # OVERFLOW

      @cmpdi = ->
        usAddr = _this.M6809PostByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.getRegD(), usTemp

      @cmpyi = ->
        usAddr = _this.M6809PostByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regY, usTemp

      @ldyi = ->
        usAddr = _this.M6809PostByte()
        _this.regY = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regY
        _this.regCC &= ~2 # OVERFLOW

      @styi = ->
        usAddr = _this.M6809PostByte()
        _this.M6809WriteWord usAddr, _this.regY
        _this._flagnz16 _this.regY
        _this.regCC &= ~2 # OVERFLOW

      @cmpde = ->
        usAddr = _this.nextPCWord()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.getRegD(), usTemp

      @cmpye = ->
        usAddr = _this.nextPCWord()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regY, usTemp

      @ldye = ->
        usAddr = _this.nextPCWord()
        _this.regY = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regY
        _this.regCC &= ~2 # OVERFLOW

      @stye = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteWord usAddr, _this.regY
        _this._flagnz16 _this.regY
        _this.regCC &= ~2 # OVERFLOW

      @lds = ->
        _this.regS = _this.nextPCWord()
        _this._flagnz16 _this.regS
        _this.regCC &= ~2 # OVERFLOW

      @ldsd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.regS = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regS
        _this.regCC &= ~2 # OVERFLOW

      @stsd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.M6809WriteWord usAddr, _this.regS
        _this._flagnz16 _this.regS
        _this.regCC &= ~2 # OVERFLOW

      @ldsi = ->
        usAddr = _this.M6809PostByte()
        _this.regS = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regS
        _this.regCC &= ~2 # OVERFLOW

      @stsi = ->
        usAddr = _this.M6809PostByte()
        _this.M6809WriteWord usAddr, _this.regS
        _this._flagnz16 _this.regS
        _this.regCC &= ~2 # OVERFLOW

      @ldse = ->
        usAddr = _this.nextPCWord()
        _this.regS = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regS
        _this.regCC &= ~2 # OVERFLOW

      @stse = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteWord usAddr, _this.regS
        _this._flagnz16 _this.regS
        _this.regCC &= ~2 # OVERFLOW

      @p10 = ->
        op = _this.nextPCByte()
        _this.iClocks -= c6809Cycles2[op] # Subtract execution time
        console.log (_this.regPC - 1).toString(16) + ": " + _this.mnemonics10[op]  if _this.debug
        instruction = _this.instructions10[op]
        unless instruction?
          console.log "*** illegal p10 opcode: " + op.toString(16) + " at " + (_this.regPC - 1).toString(16)
          _this.halt()
        else
          instruction()

      @instructions10 = [ null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, @lbrn, @lbhi, @lbls, @lbcc, @lbcs, @lbne, @lbeq, @lbvc, @lbvs, @lbpl, @lbmi, @lbge, @lblt, @lbgt, @lble, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, @swi2, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, @cmpd, null, null, null, null, null, null, null, null, @cmpy, null, @ldy, null, null, null, null, @cmpdd, null, null, null, null, null, null, null, null, @cmpyd, null, @ldyd, @sty, null, null, null, @cmpdi, null, null, null, null, null, null, null, null, @cmpyi, null, @ldyi, @styi, null, null, null, @cmpde, null, null, null, null, null, null, null, null, @cmpye, null, @ldye, @stye, null, null, null, null, null, null, null, null, null, null, null, null, null, null, @lds, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, @ldsd, @stsd, null, null, null, null, null, null, null, null, null, null, null, null, null, null, @ldsi, @stsi, null, null, null, null, null, null, null, null, null, null, null, null, null, null, @ldse, @stse ]
      @mnemonics10 = [ "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "lbrn ", "lbhi ", "lbls ", "lbcc ", "lbcs ", "lbne ", "lbeq ", "lbvc ", "lbvs ", "lbpl ", "lbmi ", "lbge ", "lblt ", "lbgt ", "lble ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "swi2 ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "cmpd ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "cmpy ", "     ", "ldy  ", "     ", "     ", "     ", "     ", "cmpdd", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "cmpyd", "     ", "ldyd ", "sty  ", "     ", "     ", "     ", "cmpdi", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "cmpyi", "     ", "ldyi ", "styi ", "     ", "     ", "     ", "cmpde", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "cmpye", "     ", "ldye ", "stye ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "lds  ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "ldsd ", "stsd ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "ldsi ", "stsi ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "     ", "ldse ", "stse " ]
      
      # P10 end 
      
      # P11 start 
      @swi3 = ->
        _this.regCC |= 0x80 # Set entire flag to indicate whole machine state on stack
        _this.M6809PUSHW _this.regPC
        _this.M6809PUSHW _this.regU
        _this.M6809PUSHW _this.regY
        _this.M6809PUSHW _this.regX
        _this.M6809PUSHB _this.regDP
        _this.M6809PUSHB _this.regA
        _this.M6809PUSHB _this.regB
        _this.M6809PUSHB _this.regCC
        _this._goto _this.M6809ReadWord(0xfff2)

      @cmpu = ->
        usTemp = _this.nextPCWord()
        _this._cmp16 _this.regU, usTemp

      @cmps = ->
        usTemp = _this.nextPCWord()
        _this._cmp16 _this.regS, usTemp

      @cmpud = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regU, usTemp

      @cmpsd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regS, usTemp

      @cmpui = ->
        usAddr = _this.M6809PostByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regU, usTemp

      @cmpsi = ->
        usAddr = _this.M6809PostByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regS, usTemp

      @cmpue = ->
        usAddr = _this.nextPCWord()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regU, usTemp

      @cmpse = ->
        usAddr = _this.nextPCWord()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regS, usTemp

      @instructions11 = []
      @mnemonics11 = []
      @add11 = (op, name) ->
        _this.instructions11[op] = _this[name]
        _this.mnemonics11[op] = name

      @init11 = ->
        i = 0

        while i < 256
          _this.instructions11[i] = null
          _this.mnemonics11[i] = "     "
          i++
        x = [
          op: 0x3f
          name: "swi3"
        ,
          op: 0x83
          name: "cmpu"
        ,
          op: 0x8c
          name: "cmps"
        ,
          op: 0x93
          name: "cmpud"
        ,
          op: 0x9c
          name: "cmpsd"
        ,
          op: 0xa3
          name: "cmpui"
        ,
          op: 0xac
          name: "cmpsi"
        ,
          op: 0xb3
          name: "cmpue"
        ,
          op: 0xbc
          name: "cmpse"
         ]
        $.each x, (i, o) ->
          _this.instructions11[o.op] = _this[o.name]
          _this.mnemonics11[o.op] = o.name


      @p11 = ->
        op = _this.nextPCByte()
        _this.iClocks -= c6809Cycles2[op] # Subtract execution time
        console.log (_this.regPC - 1).toString(16) + ": " + _this.mnemonics11[op]  if _this.debug
        instruction = _this.instructions11[op]
        unless instruction?
          console.log "*** illegal p11 opcode: " + op.toString(16)
          _this.halt()
        else
          instruction()

      
      # p11 end 
      @nop = ->

      @sync = ->

      @lbra = ->
        
        # LBRA - relative jump 
        sTemp = makeSignedWord(_this.nextPCWord())
        _this.regPC += sTemp

      @lbsr = ->
        
        # LBSR - relative call 
        sTemp = makeSignedWord(_this.nextPCWord())
        _this.M6809PUSHW _this.regPC
        _this.regPC += sTemp

      @daa = ->
        cf = 0
        msn = _this.regA & 0xf0
        lsn = _this.regA & 0x0f
        cf |= 0x06  if lsn > 0x09 or _this.regCC & 0x20
        cf |= 0x60  if msn > 0x80 and lsn > 0x09
        cf |= 0x60  if msn > 0x90 or _this.regCC & 0x01
        usTemp = cf + _this.regA
        _this.regCC &= ~(1 | 8 | 4 | 2) # CARRY 
# NEGATIVE 
# ZERO 
# OVERFLOW
        _this.regCC |= 1  if usTemp & 0x100 # CARRY
        _this.regA = usTemp & 0xff
        _this._flagnz _this.regA

      @orcc = ->
        _this.regCC |= _this.nextPCByte()

      @andcc = ->
        _this.regCC &= _this.nextPCByte()

      @sex = ->
        _this.regA = (if (_this.regB & 0x80) then 0xFF else 0x00)
        _this.regCC &= ~(4 | 8) # ZERO 
# NEGATIVE
        d = _this.getRegD()
        _this._flagnz16 d
        _this.regCC &= ~2 # OVERFLOW

      @_setreg = (name, value) ->
        
        # console.log(name + '=' + value.toString(16));
        if name is "D"
          _this.setRegD value
        else
          _this["reg" + name] = value

      @M6809TFREXG = (ucPostByte, bExchange) ->
        ucTemp = ucPostByte & 0x88
        if ucTemp is 0x80 or ucTemp is 0x08
          console.log "**** M6809TFREXG problem..."
          ucTemp = 0 # PROBLEM!
        srname = undefined
        srcval = undefined
        switch ucPostByte & 0xf0
          when 0x00
            srname = "D"
            srcval = _this.getRegD()
          when 0x10
            srname = "X"
            srcval = _this.regX
          when 0x20
            srname = "Y"
            srcval = _this.regY
          when 0x30
            srname = "U"
            srcval = _this.regU
          when 0x40
            srname = "S"
            srcval = _this.regS
          when 0x50
            srname = "PC"
            srcval = _this.regPC
          when 0x80
            srname = "A"
            srcval = _this.regA
          when 0x90
            srname = "B"
            srcval = _this.regB
          when 0xA0
            srname = "CC"
            srcval = _this.regCC
          when 0xB0
            srname = "DP"
            srcval = _this.regDP
          else
            console.log "illegal src register in M6809TFREXG"
            _this.halt()
        switch ucPostByte & 0xf
          when 0x00
            
            # console.log('EXG dst: D=' + this.getRegD().toString(16));
            _this._setreg srname, _this.getRegD()  if bExchange
            _this.setRegD srcval
          when 0x1
            
            # console.log('EXG dst: X=' + this.regX.toString(16));
            _this._setreg srname, _this.regX  if bExchange
            _this.regX = srcval
          when 0x2
            
            # console.log('EXG dst: Y=' + this.regY.toString(16));
            _this._setreg srname, _this.regY  if bExchange
            _this.regY = srcval
          when 0x3
            
            # console.log('EXG dst: U=' + this.regU.toString(16));
            _this._setreg srname, _this.regU  if bExchange
            _this.regU = srcval
          when 0x4
            
            # console.log('EXG dst: S=' + this.regS.toString(16));
            _this._setreg srname, _this.regS  if bExchange
            _this.regS = srcval
          when 0x5
            
            # console.log('EXG dst: PC=' + this.regPC.toString(16));
            _this._setreg srname, _this.regPC  if bExchange
            _this._goto srcval
          when 0x8
            
            # console.log('EXG dst: A=' + this.regA.toString(16));
            _this._setreg srname, _this.regA  if bExchange
            _this.regA = 0xff & srcval
          when 0x9
            
            # console.log('EXG dst: B=' + this.regB.toString(16));
            _this._setreg srname, _this.regB  if bExchange
            _this.regB = 0xff & srcval
          when 0xA
            
            # console.log('EXG dst: CC=' + this.regCC.toString(16));
            _this._setreg srname, _this.regCC  if bExchange
            _this.regCC = 0xff & srcval
          when 0xB
            
            # console.log('EXG dst: DP=' + this.regDP.toString(16));
            _this._setreg srname, _this.regDP  if bExchange
            _this.regDP = srcval
          else
            console.log "illegal dst register in M6809TFREXG"
            _this.halt()

      @exg = ->
        ucTemp = _this.nextPCByte()
        _this.M6809TFREXG ucTemp, true

      @tfr = ->
        ucTemp = _this.nextPCByte()
        _this.M6809TFREXG ucTemp, false

      @bra = ->
        offset = makeSignedByte(_this.nextPCByte())
        _this.regPC += offset

      @brn = ->
        _this.regPC++ # never.

      @bhi = ->
        offset = makeSignedByte(_this.nextPCByte())
        # CARRY 
        # ZERO 
        _this.regPC += offset  unless _this.regCC & (1 | 4)

      @bls = ->
        offset = makeSignedByte(_this.nextPCByte())
        # CARRY 
        # ZERO 
        _this.regPC += offset  if _this.regCC & (1 | 4)

      @branchIf = (go) ->
        offset = makeSignedByte(_this.nextPCByte())
        _this.regPC += offset  if go

      @branch = (flag, ifSet) ->
        _this.branchIf (_this.regCC & flag) is ((if ifSet then flag else 0))

      @bcc = ->
        _this.branch 1, false # CARRY

      @bcs = ->
        _this.branch 1, true # CARRY

      @bne = ->
        _this.branch 4, false # ZERO

      @beq = ->
        _this.branch 4, true # ZERO

      @bvc = ->
        _this.branch 2, false # OVERFLOW

      @bvs = ->
        _this.branch 2, true # OVERFLOW

      @bpl = ->
        _this.branch 8, false # NEGATIVE

      @bmi = ->
        _this.branch 8, true # NEGATIVE

      @bge = ->
        go = not ((_this.regCC & 8) ^ (_this.regCC & 2) << 2) # NEGATIVE 
# OVERFLOW
        _this.branchIf go

      @blt = ->
        go = (_this.regCC & 8) ^ (_this.regCC & 2) << 2 # NEGATIVE 
# OVERFLOW
        _this.branchIf go isnt 0

      @bgt = ->
        bit = (_this.regCC & 8) ^ (_this.regCC & 2) << 2 # NEGATIVE 
# OVERFLOW
        go = bit is 0 or (_this.regCC & 4) isnt 0 # ZERO
        _this.branchIf go

      @ble = ->
        bit = (_this.regCC & 8) ^ (_this.regCC & 2) << 2 # NEGATIVE 
# OVERFLOW
        go = bit isnt 0 or (_this.regCC & 4) isnt 0 # ZERO
        _this.branchIf go

      @leax = ->
        _this.regX = _this.M6809PostByte()
        _this.regCC &= ~4 # ZERO
        _this.regCC |= 4  if _this.regX is 0 # ZERO

      @leay = ->
        _this.regY = _this.M6809PostByte()
        _this.regCC &= ~4 # ZERO
        _this.regCC |= 4  if _this.regY is 0 # ZERO

      @leas = ->
        _this.regS = _this.M6809PostByte()

      @leau = ->
        _this.regU = _this.M6809PostByte()

      @pshs = ->
        ucTemp = _this.nextPCByte()
        _this.M6809PSHS ucTemp

      @puls = ->
        ucTemp = _this.nextPCByte()
        _this.M6809PULS ucTemp

      @pshu = ->
        ucTemp = _this.nextPCByte()
        _this.M6809PSHU ucTemp

      @pulu = ->
        ucTemp = _this.nextPCByte()
        _this.M6809PULU ucTemp

      @rts = ->
        _this._goto _this.M6809PULLW()

      @abx = ->
        _this.regX += _this.regB

      @rti = ->
        _this.regCC = _this.M6809PULLB()
        if _this.regCC & 0x80
          _this.iClocks -= 9
          _this.regA = _this.M6809PULLB()
          _this.regB = _this.M6809PULLB()
          _this.regDP = _this.M6809PULLB()
          _this.regX = _this.M6809PULLW()
          _this.regY = _this.M6809PULLW()
          _this.regU = _this.M6809PULLW()
        _this._goto _this.M6809PULLW()

      @cwai = ->
        _this.regCC &= _this.nextPCByte()

      @mul = ->
        usTemp = _this.regA * _this.regB
        if usTemp
          _this.regCC &= ~4 # ZERO
        else # ZERO
          _this.regCC |= 4
        if usTemp & 0x80
          _this.regCC |= 1 # CARRY
        else # CARRY
          _this.regCC &= ~1
        _this.setRegD usTemp

      @swi = ->
        _this.regCC |= 0x80 # Indicate whole machine state is stacked
        _this.M6809PUSHW _this.regPC
        _this.M6809PUSHW _this.regU
        _this.M6809PUSHW _this.regY
        _this.M6809PUSHW _this.regX
        _this.M6809PUSHB _this.regDP
        _this.M6809PUSHB _this.regB
        _this.M6809PUSHB _this.regA
        _this.M6809PUSHB _this.regCC
        _this.regCC |= 0x50 # Disable further interrupts
        _this._goto _this.M6809ReadWord(0xfffa)

      @nega = ->
        _this.regA = _this._neg(_this.regA)

      @coma = ->
        _this.regA = _this._com(_this.regA)

      @lsra = ->
        _this.regA = _this._lsr(_this.regA)

      @rora = ->
        _this.regA = _this._ror(_this.regA)

      @asra = ->
        _this.regA = _this._asr(_this.regA)

      @asla = ->
        _this.regA = _this._asl(_this.regA)

      @rola = ->
        _this.regA = _this._rol(_this.regA)

      @deca = ->
        _this.regA = _this._dec(_this.regA)

      @inca = ->
        _this.regA = _this._inc(_this.regA)

      @tsta = ->
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regA

      @clra = ->
        _this.regA = 0
        _this.regCC &= ~(8 | 2 | 1) # NEGATIVE 
# OVERFLOW 
# CARRY
        _this.regCC |= 4 # ZERO

      @negb = ->
        _this.regB = _this._neg(_this.regB)

      @comb = ->
        _this.regB = _this._com(_this.regB)

      @lsrb = ->
        _this.regB = _this._lsr(_this.regB)

      @rorb = ->
        _this.regB = _this._ror(_this.regB)

      @asrb = ->
        _this.regB = _this._asr(_this.regB)

      @aslb = ->
        _this.regB = _this._asl(_this.regB)

      @rolb = ->
        _this.regB = _this._rol(_this.regB)

      @decb = ->
        _this.regB = _this._dec(_this.regB)

      @incb = ->
        _this.regB = _this._inc(_this.regB)

      @tstb = ->
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regB

      @clrb = ->
        _this.regB = 0
        _this.regCC &= ~(8 | 2 | 1) # NEGATIVE 
# OVERFLOW 
# CARRY
        _this.regCC |= 4 # ZERO

      @negi = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.M6809WriteByte usAddr, _this._neg(ucTemp)

      @comi = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.M6809WriteByte usAddr, _this._com(ucTemp)

      @lsri = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.M6809WriteByte usAddr, _this._lsr(ucTemp)

      @rori = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.M6809WriteByte usAddr, _this._ror(ucTemp)

      @asri = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.M6809WriteByte usAddr, _this._asr(ucTemp)

      @asli = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.M6809WriteByte usAddr, _this._asl(ucTemp)

      @roli = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.M6809WriteByte usAddr, _this._rol(ucTemp)

      @deci = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.M6809WriteByte usAddr, _this._dec(ucTemp)

      @inci = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.M6809WriteByte usAddr, _this._inc(ucTemp)

      @tsti = ->
        usAddr = _this.M6809PostByte()
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        val = _this.M6809ReadByte(usAddr)
        _this._flagnz val

      @jmpi = ->
        _this._goto _this.M6809PostByte()

      @clri = ->
        usAddr = _this.M6809PostByte()
        _this.M6809WriteByte usAddr, 0
        _this.regCC &= ~(2 | 1 | 8) # OVERFLOW 
# CARRY 
# NEGATIVE
        _this.regCC |= 4 # ZERO

      @nege = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this._neg(_this.M6809ReadByte(usAddr))

      @come = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this._com(_this.M6809ReadByte(usAddr))

      @lsre = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this._lsr(_this.M6809ReadByte(usAddr))

      @rore = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this._ror(_this.M6809ReadByte(usAddr))

      @asre = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this._asr(_this.M6809ReadByte(usAddr))

      @asle = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this._asl(_this.M6809ReadByte(usAddr))

      @role = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this._rol(_this.M6809ReadByte(usAddr))

      @dece = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this._dec(_this.M6809ReadByte(usAddr))

      @ince = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this._inc(_this.M6809ReadByte(usAddr))

      @tste = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz ucTemp

      @jmpe = ->
        _this._goto _this.M6809ReadWord(_this.regPC)

      @clre = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, 0
        _this.regCC &= ~(1 | 2 | 8) # CARRY 
# OVERFLOW 
# NEGATIVE
        _this.regCC |= 4 # ZERO

      @suba = ->
        _this.regA = _this._sub(_this.regA, _this.nextPCByte())

      @cmpa = ->
        ucTemp = _this.nextPCByte()
        _this._cmp _this.regA, ucTemp

      @sbca = ->
        ucTemp = _this.nextPCByte()
        _this.regA = _this._sbc(_this.regA, ucTemp)

      @subd = ->
        usTemp = _this.nextPCWord()
        _this.setRegD _this._sub16(_this.getRegD(), usTemp)

      @anda = ->
        ucTemp = _this.nextPCByte()
        _this.regA = _this._and(_this.regA, ucTemp)

      @bita = ->
        ucTemp = _this.nextPCByte()
        _this._and _this.regA, ucTemp

      @lda = ->
        _this.regA = _this.nextPCByte()
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regA

      @eora = ->
        ucTemp = _this.nextPCByte()
        _this.regA = _this._eor(_this.regA, ucTemp)

      @adca = ->
        ucTemp = _this.nextPCByte()
        _this.regA = _this._adc(_this.regA, ucTemp)

      @ora = ->
        ucTemp = _this.nextPCByte()
        _this.regA = _this._or(_this.regA, ucTemp)

      @adda = ->
        ucTemp = _this.nextPCByte()
        _this.regA = _this._add(_this.regA, ucTemp)

      @cmpx = ->
        usTemp = _this.nextPCWord()
        _this._cmp16 _this.regX, usTemp

      @bsr = ->
        sTemp = makeSignedByte(_this.nextPCByte())
        _this.M6809PUSHW _this.regPC
        _this.regPC += sTemp

      @ldx = ->
        usTemp = _this.nextPCWord()
        _this.regX = usTemp
        _this._flagnz16 usTemp
        _this.regCC &= ~2 # OVERFLOW

      @subad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._sub(_this.regA, ucTemp)

      @cmpad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._cmp _this.regA, ucTemp

      @sbcad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._sbc(_this.regA, ucTemp)

      @subdd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this.setRegD _this._sub16(_this.getRegD(), usTemp)

      @andad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._and(_this.regA, ucTemp)

      @bitad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._and _this.regA, ucTemp

      @ldad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.regA = _this.M6809ReadByte(usAddr)
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regA

      @stad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.M6809WriteByte usAddr, _this.regA
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regA

      @eorad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._eor(_this.regA, ucTemp)

      @adcad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._adc(_this.regA, ucTemp)

      @orad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._or(_this.regA, ucTemp)

      @addad = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._add(_this.regA, ucTemp)

      @cmpxd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regX, usTemp

      @jsrd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.M6809PUSHW _this.regPC
        _this._goto usAddr

      @ldxd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.regX = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regX
        _this.regCC &= ~2 # OVERFLOW

      @stxd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.M6809WriteWord usAddr, _this.regX
        _this._flagnz16 _this.regX
        _this.regCC &= ~2 # OVERFLOW

      @subax = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._sub(_this.regA, ucTemp)

      @cmpax = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._cmp _this.regA, ucTemp

      @sbcax = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._sbc(_this.regA, ucTemp)

      @subdx = ->
        usAddr = _this.M6809PostByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this.setRegD _this._sub16(_this.getRegD(), usTemp)

      @andax = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._and(_this.regA, ucTemp)

      @bitax = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._and _this.regA, ucTemp

      @ldax = ->
        usAddr = _this.M6809PostByte()
        _this.regA = _this.M6809ReadByte(usAddr)
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regA

      @stax = ->
        usAddr = _this.M6809PostByte()
        _this.M6809WriteByte usAddr, _this.regA
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regA

      @eorax = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._eor(_this.regA, ucTemp)

      @adcax = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._adc(_this.regA, ucTemp)

      @orax = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._or(_this.regA, ucTemp)

      @addax = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regA = _this._add(_this.regA, ucTemp)

      @cmpxx = ->
        usAddr = _this.M6809PostByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this._cmp16 _this.regX, usTemp

      @jsrx = ->
        usAddr = _this.M6809PostByte()
        _this.M6809PUSHW _this.regPC
        _this._goto usAddr

      @ldxx = ->
        usAddr = _this.M6809PostByte()
        _this.regX = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regX
        _this.regCC &= ~2 # OVERFLOW

      @stxx = ->
        usAddr = _this.M6809PostByte()
        _this.M6809WriteWord usAddr, _this.regX
        _this._flagnz16 _this.regX
        _this.regCC &= ~2 # OVERFLOW

      @subae = ->
        usAddr = _this.nextPCWord()
        _this.regA = _this._sub(_this.regA, _this.M6809ReadByte(usAddr))

      @cmpae = ->
        usAddr = _this.nextPCWord()
        _this._cmp _this.regA, _this.M6809ReadByte(usAddr)

      @sbcae = ->
        usAddr = _this.nextPCWord()
        _this.regA = _this._sbc(_this.regA, _this.M6809ReadByte(usAddr))

      @subde = ->
        usAddr = _this.nextPCWord()
        _this.setRegD _this._sub16(_this.getRegD(), _this.M6809ReadWord(usAddr))

      @andae = ->
        usAddr = _this.nextPCWord()
        _this.regA = _this._and(_this.regA, _this.M6809ReadByte(usAddr))

      @bitae = ->
        usAddr = _this.nextPCWord()
        _this._and _this.regA, _this.M6809ReadByte(usAddr)

      @ldae = ->
        usAddr = _this.nextPCWord()
        _this.regA = _this.M6809ReadByte(usAddr)
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regA

      @stae = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this.regA
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regA

      @eorae = ->
        usAddr = _this.nextPCWord()
        _this.regA = _this._eor(_this.regA, _this.M6809ReadByte(usAddr))

      @adcae = ->
        usAddr = _this.nextPCWord()
        _this.regA = _this._adc(_this.regA, _this.M6809ReadByte(usAddr))

      @orae = ->
        usAddr = _this.nextPCWord()
        _this.regA = _this._or(_this.regA, _this.M6809ReadByte(usAddr))

      @addae = ->
        usAddr = _this.nextPCWord()
        _this.regA = _this._add(_this.regA, _this.M6809ReadByte(usAddr))

      @cmpxe = ->
        usAddr = _this.nextPCWord()
        _this._cmp16 _this.regX, _this.M6809ReadWord(usAddr)

      @jsre = ->
        usAddr = _this.nextPCWord()
        _this.M6809PUSHW _this.regPC
        _this._goto usAddr

      @ldxe = ->
        usAddr = _this.nextPCWord()
        _this.regX = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regX
        _this.regCC &= ~2 # OVERFLOW

      @stxe = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteWord usAddr, _this.regX
        _this._flagnz16 _this.regX
        _this.regCC &= ~2 # OVERFLOW

      @subb = ->
        ucTemp = _this.nextPCByte()
        _this.regB = _this._sub(_this.regB, ucTemp)

      @cmpb = ->
        ucTemp = _this.nextPCByte()
        _this._cmp _this.regB, ucTemp

      @sbcb = ->
        ucTemp = _this.nextPCByte()
        _this.regB = _this._sbc(_this.regB, ucTemp)

      @addd = ->
        usTemp = _this.nextPCWord()
        _this.setRegD _this._add16(_this.getRegD(), usTemp)

      @andb = ->
        ucTemp = _this.nextPCByte()
        _this.regB = _this._and(_this.regB, ucTemp)

      @bitb = ->
        ucTemp = _this.nextPCByte()
        _this._and _this.regB, ucTemp

      @ldb = ->
        _this.regB = _this.nextPCByte()
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regB

      @eorb = ->
        ucTemp = _this.nextPCByte()
        _this.regB = _this._eor(_this.regB, ucTemp)

      @adcb = ->
        ucTemp = _this.nextPCByte()
        _this.regB = _this._adc(_this.regB, ucTemp)

      @orb = ->
        ucTemp = _this.nextPCByte()
        _this.regB = _this._or(_this.regB, ucTemp)

      @addb = ->
        ucTemp = _this.nextPCByte()
        _this.regB = _this._add(_this.regB, ucTemp)

      @ldd = ->
        d = _this.nextPCWord()
        _this.setRegD d
        _this._flagnz16 d
        _this.regCC &= ~2 # OVERFLOW

      @ldu = ->
        _this.regU = _this.nextPCWord()
        _this._flagnz16 _this.regU
        _this.regCC &= ~2 # OVERFLOW

      @sbbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._sub(_this.regB, ucTemp)

      @cmpbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._cmp _this.regB, ucTemp

      @sbcd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._sbc(_this.regB, ucTemp)

      @adddd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this.setRegD _this._add16(_this.getRegD(), usTemp)

      @andbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._and(_this.regB, ucTemp)

      @bitbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._and _this.regB, ucTemp

      @ldbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.regB = _this.M6809ReadByte(usAddr)
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regB

      @stbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.M6809WriteByte usAddr, _this.regB
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regB

      @eorbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._eor(_this.regB, ucTemp)

      @adcbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._adc(_this.regB, ucTemp)

      @orbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._or(_this.regB, ucTemp)

      @addbd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._add(_this.regB, ucTemp)

      @lddd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        d = _this.M6809ReadWord(usAddr)
        _this.setRegD d
        _this._flagnz16 d
        _this.regCC &= ~2 # OVERFLOW

      @stdd = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        d = _this.getRegD()
        _this.M6809WriteWord usAddr, d
        _this._flagnz16 d
        _this.regCC &= ~2 # OVERFLOW

      @ldud = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.regU = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regU
        _this.regCC &= ~2 # OVERFLOW

      @stud = ->
        usAddr = _this.regDP * 256 + _this.nextPCByte()
        _this.M6809WriteWord usAddr, _this.regU
        _this._flagnz16 _this.regU
        _this.regCC &= ~2 # OVERFLOW

      @subbx = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._sub(_this.regB, ucTemp)

      @cmpbx = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._cmp _this.regB, ucTemp

      @sbcbx = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._sbc(_this.regB, ucTemp)

      @adddx = ->
        usAddr = _this.M6809PostByte()
        usTemp = _this.M6809ReadWord(usAddr)
        _this.setRegD _this._add16(_this.getRegD(), usTemp)

      @andbx = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._and(_this.regB, ucTemp)

      @bitbx = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._and _this.regB, ucTemp

      @ldbx = ->
        usAddr = _this.M6809PostByte()
        _this.regB = _this.M6809ReadByte(usAddr)
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regB

      @stbx = ->
        usAddr = _this.M6809PostByte()
        _this.M6809WriteByte usAddr, _this.regB
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regB

      @eorbx = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._eor(_this.regB, ucTemp)

      @adcbx = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._adc(_this.regB, ucTemp)

      @orbx = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._or(_this.regB, ucTemp)

      @addbx = ->
        usAddr = _this.M6809PostByte()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._add(_this.regB, ucTemp)

      @lddx = ->
        usAddr = _this.M6809PostByte()
        d = _this.M6809ReadWord(usAddr)
        _this.setRegD d
        _this._flagnz16 d
        _this.regCC &= ~2 # OVERFLOW

      @stdx = ->
        usAddr = _this.M6809PostByte()
        d = _this.getRegD()
        _this.M6809WriteWord usAddr, d
        _this._flagnz16 d
        _this.regCC &= ~2 # OVERFLOW

      @ldux = ->
        usAddr = _this.M6809PostByte()
        _this.regU = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regU
        _this.regCC &= ~2 # OVERFLOW

      @stux = ->
        usAddr = _this.M6809PostByte()
        _this.M6809WriteWord usAddr, _this.regU
        _this._flagnz16 _this.regU
        _this.regCC &= ~2 # OVERFLOW

      @subbe = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._sub(_this.regB, ucTemp)

      @cmpbe = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._cmp _this.regB, ucTemp

      @sbcbe = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._sbc(_this.regB, ucTemp)

      @addde = ->
        usAddr = _this.nextPCWord()
        usTemp = _this.M6809ReadWord(usAddr)
        _this.setRegD _this._add16(_this.getRegD(), usTemp)

      @andbe = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._and(_this.regB, ucTemp)

      @bitbe = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this._and _this.regB, ucTemp

      @ldbe = ->
        usAddr = _this.nextPCWord()
        _this.regB = _this.M6809ReadByte(usAddr)
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regB

      @stbe = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteByte usAddr, _this.regB
        _this.regCC &= ~(4 | 8 | 2) # ZERO 
# NEGATIVE 
# OVERFLOW
        _this._flagnz _this.regB

      @eorbe = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._eor(_this.regB, ucTemp)

      @adcbe = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._adc(_this.regB, ucTemp)

      @orbe = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._or(_this.regB, ucTemp)

      @addbe = ->
        usAddr = _this.nextPCWord()
        ucTemp = _this.M6809ReadByte(usAddr)
        _this.regB = _this._add(_this.regB, ucTemp)

      @ldde = ->
        usAddr = _this.nextPCWord()
        val = _this.M6809ReadWord(usAddr)
        _this.setRegD val
        _this._flagnz16 val
        _this.regCC &= ~2 # OVERFLOW

      @stde = ->
        usAddr = _this.nextPCWord()
        d = _this.getRegD()
        _this.M6809WriteWord usAddr, d
        _this._flagnz16 d
        _this.regCC &= ~2 # OVERFLOW

      @ldue = ->
        usAddr = _this.nextPCWord()
        _this.regU = _this.M6809ReadWord(usAddr)
        _this._flagnz16 _this.regU
        _this.regCC &= ~2 # OVERFLOW

      @stue = ->
        usAddr = _this.nextPCWord()
        _this.M6809WriteWord usAddr, _this.regU
        _this._flagnz16 _this.regU
        _this.regCC &= ~2 # OVERFLOW

      @instructions = [ @neg, null, null, @com, @lsr, null, @ror, @asr, @asl, @rol, @dec, null, @inc, @tst, @jmp, @clr, @p10, @p11, @nop, @sync, null, null, @lbra, @lbsr, null, @daa, @orcc, null, @andcc, @sex, @exg, @tfr, @bra, @brn, @bhi, @bls, @bcc, @bcs, @bne, @beq, @bvc, @bvs, @bpl, @bmi, @bge, @blt, @bgt, @ble, @leax, @leay, @leas, @leau, @pshs, @puls, @pshu, @pulu, null, @rts, @abx, @rti, @cwai, @mul, null, @swi, @nega, null, null, @coma, @lsra, null, @rora, @asra, @asla, @rola, @deca, null, @inca, @tsta, null, @clra, @negb, null, null, @comb, @lsrb, null, @rorb, @asrb, @aslb, @rolb, @decb, null, @incb, @tstb, null, @clrb, @negi, null, null, @comi, @lsri, null, @rori, @asri, @asli, @roli, @deci, null, @inci, @tsti, @jmpi, @clri, @nege, null, null, @come, @lsre, null, @rore, @asre, @asle, @role, @dece, null, @ince, @tste, @jmpe, @clre, @suba, @cmpa, @sbca, @subd, @anda, @bita, @lda, null, @eora, @adca, @ora, @adda, @cmpx, @bsr, @ldx, null, @subad, @cmpad, @sbcad, @subdd, @andad, @bitad, @ldad, @stad, @eorad, @adcad, @orad, @addad, @cmpxd, @jsrd, @ldxd, @stxd, @subax, @cmpax, @sbcax, @subdx, @andax, @bitax, @ldax, @stax, @eorax, @adcax, @orax, @addax, @cmpxx, @jsrx, @ldxx, @stxx, @subae, @cmpae, @sbcae, @subde, @andae, @bitae, @ldae, @stae, @eorae, @adcae, @orae, @addae, @cmpxe, @jsre, @ldxe, @stxe, @subb, @cmpb, @sbcb, @addd, @andb, @bitb, @ldb, @eorb, @eorb, @adcb, @orb, @addb, @ldd, null, @ldu, null, @sbbd, @cmpbd, @sbcd, @adddd, @andbd, @bitbd, @ldbd, @stbd, @eorbd, @adcbd, @orbd, @addbd, @lddd, @stdd, @ldud, @stud, @subbx, @cmpbx, @sbcbx, @adddx, @andbx, @bitbx, @ldbx, @stbx, @eorbx, @adcbx, @orbx, @addbx, @lddx, @stdx, @ldux, @stux, @subbe, @cmpbe, @sbcbe, @addde, @andbe, @bitbe, @ldbe, @stbe, @eorbe, @adcbe, @orbe, @addbe, @ldde, @stde, @ldue, @stue ]
      @mnemonics = [ "neg  ", "     ", "     ", "com  ", "lsr  ", "     ", "ror  ", "asr  ", "asl  ", "rol  ", "dec  ", "     ", "inc  ", "tst  ", "jmp  ", "clr  ", "p10  ", "p11  ", "nop  ", "sync ", "     ", "     ", "lbra ", "lbsr ", "     ", "daa  ", "orcc ", "     ", "andcc", "sex  ", "exg  ", "tfr  ", "bra  ", "brn  ", "bhi  ", "bls  ", "bcc  ", "bcs  ", "bne  ", "beq  ", "bvc  ", "bvs  ", "bpl  ", "bmi  ", "bge  ", "blt  ", "bgt  ", "ble  ", "leax ", "leay ", "leas ", "leau ", "pshs ", "puls ", "pshu ", "pulu ", "     ", "rts  ", "abx  ", "rti  ", "cwai ", "mul  ", "     ", "swi  ", "nega ", "     ", "     ", "coma ", "lsra ", "     ", "rora ", "asra ", "asla ", "rola ", "deca ", "     ", "inca ", "tsta ", "     ", "clra ", "negb ", "     ", "     ", "comb ", "lsrb ", "     ", "rorb ", "asrb ", "aslb ", "rolb ", "decb ", "     ", "incb ", "tstb ", "     ", "clrb ", "negi ", "     ", "     ", "comi ", "lsri ", "     ", "rori ", "asri ", "asli ", "roli ", "deci ", "     ", "inci ", "tsti ", "jmpi ", "clri ", "nege ", "     ", "     ", "come ", "lsre ", "     ", "rore ", "asre ", "asle ", "role ", "dece ", "     ", "ince ", "tste ", "jmpe ", "clre ", "suba ", "cmpa ", "sbca ", "subd ", "anda ", "bita ", "lda  ", "     ", "eora ", "adca ", "ora  ", "adda ", "cmpx ", "bsr  ", "ldx  ", "     ", "subad", "cmpad", "sbcad", "subdd", "andad", "bitad", "ldad ", "stad ", "eorad", "adcad", "orad ", "addad", "cmpxd", "jsrd ", "ldxd ", "stxd ", "subax", "cmpax", "sbcax", "subdx", "andax", "bitax", "ldax ", "stax ", "eorax", "adcax", "orax ", "addax", "cmpxx", "jsrx ", "ldxx ", "stxx ", "subae", "cmpae", "sbcae", "subde", "andae", "bitae", "ldae ", "stae ", "eorae", "adcae", "orae ", "addae", "cmpxe", "jsre ", "ldxe ", "stxe ", "subb ", "cmpb ", "sbcb ", "addd ", "andb ", "bitb ", "ldb  ", "eorb ", "eorb ", "adcb ", "orb  ", "addb ", "ldd  ", "     ", "ldu  ", "     ", "sbbd ", "cmpbd", "sbcd ", "adddd", "andbd", "bitbd", "ldbd ", "stbd ", "eorbd", "adcbd", "orbd ", "addbd", "lddd ", "stdd ", "ldud ", "stud ", "subbx", "cmpbx", "sbcbx", "adddx", "andbx", "bitbx", "ldbx ", "stbx ", "eorbx", "adcbx", "orbx ", "addbx", "lddx ", "stdx ", "ldux ", "stux ", "subbe", "cmpbe", "sbcbe", "addde", "andbe", "bitbe", "ldbe ", "stbe ", "eorbe", "adcbe", "orbe ", "addbe", "ldde ", "stde ", "ldue ", "stue " ]
      @buffer = new ArrayBuffer(0x30000)
      @mem = new Uint8Array(@buffer)
      @view = new DataView(@buffer, 0)
      @init11()
    Emulator::dumpmem = (addr, count) ->
      a = addr

      while a < addr + count
        console.log a.toString(16) + " " + @hex(@M6809ReadByte(a), 2)
        a++

    Emulator::dumpstack = (count) ->
      addr = @regS
      i = 0

      while i < count
        console.log @hex(@M6809ReadWord(addr), 4)
        addr += 2
        i++

    Emulator
  )()
  mc6809.Emulator = Emulator
) mc6809 or (mc6809 = {})
